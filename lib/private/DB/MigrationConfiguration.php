<?php
/**
 * @author Thomas Müller <thomas.mueller@tmit.eu>
 *
 * @copyright Copyright (c) 2016, ownCloud GmbH
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */
namespace OC\DB;

use Doctrine\DBAL\Schema\Column;
use Doctrine\DBAL\Schema\Table;
use Doctrine\DBAL\Types\Type;
use OC\Migration\SimpleOutput;
use OCP\IDBConnection;
use OCP\Migration\IOutput;

class MigrationConfiguration {

	/** @var boolean */
	private $migrationTableCreated;
	/** @var array */
	private $migrations;

	/** @var IOutput */
	private $output;

	function __construct($appName, Connection $connection, IOutput $output = null) {
		$this->appName = $appName;
		$this->connection = $connection;
		$this->output = $output;
		if (is_null($this->output)) {
			$this->output = new SimpleOutput(\OC::$server->getLogger(), $appName);
		}

		if ($appName === 'core') {
			$this->migrationsPath = \OC::$SERVERROOT . '/core/Migrations';
			$this->migrationsNamespace = 'OC\\Migrations';
		} else {
			$appPath = \OC_App::getAppPath($appName);
			if (!$appPath) {
				throw new \InvalidArgumentException('Path to app is not defined.');
			}
			$this->migrationsPath = "$appPath/appinfo/Migrations";
			$this->migrationsNamespace = "OCA\\$appName\\Migrations";
		}

		if (!is_dir($this->migrationsPath)) {
			if (!mkdir($this->migrationsPath)) {
				throw new \Exception("Could not create migration folder \"{$this->migrationsPath}\"");
			};
		}
	}

	private static function requireOnce($file) {
		require_once $file;
	}

	/**
	 * @return IDBConnection
	 */
	public function getConnection() {
		return $this->connection;
	}

	public function getApp() {
		return $this->appName;
	}

	public function createMigrationTable() {
		if ($this->migrationTableCreated) {
			return false;
		}

		if ($this->connection->tableExists('migrations')) {
			$this->migrationTableCreated = true;
			return false;
		}

		$tableName = $this->connection->getPrefix() . 'migrations';
		$tableName = $this->connection->getDatabasePlatform()->quoteIdentifier($tableName);

		$columns = [
			'app' => new Column($this->connection->getDatabasePlatform()->quoteIdentifier('app'), Type::getType('string'), ['length' => 255]),
			'version' => new Column($this->connection->getDatabasePlatform()->quoteIdentifier('version'), Type::getType('string'), ['length' => 255]),
		];
		$table = new Table($tableName, $columns);
		$table->setPrimaryKey([
			$this->connection->getDatabasePlatform()->quoteIdentifier('app'),
			$this->connection->getDatabasePlatform()->quoteIdentifier('version')]);
		$this->connection->getSchemaManager()->createTable($table);

		$this->migrationTableCreated = true;

		return true;
	}

	public function getMigratedVersions() {
		$this->createMigrationTable();
		$qb = $this->connection->getQueryBuilder();

		$qb->select('version')
			->from('migrations')
			->where($qb->expr()->eq('app', $qb->createNamedParameter($this->getApp())))
			->orderBy('version');

		$result = $qb->execute();
		$rows = $result->fetchAll(\PDO::FETCH_COLUMN);
		$result->closeCursor();

		return $rows;
	}

	public function getAvailableVersions() {
		$availableVersions = [];

		if (empty($this->migrations)) {
			$this->migrations = $this->findMigrations($this->migrationsPath, $this->migrationsNamespace);
		}

		foreach ($this->migrations as $version => $class) {
			$availableVersions[$version] = $class;
		}

		return $availableVersions;
	}

	/**
	 * {@inheritdoc}
	 */
	public function findMigrations($directory, $namespace = null)
	{
		$directory = realpath($directory);
		$iterator = new \RegexIterator(
			new \RecursiveIteratorIterator(
				new \RecursiveDirectoryIterator($directory, \FilesystemIterator::SKIP_DOTS),
				\RecursiveIteratorIterator::LEAVES_ONLY
			),
			'#^.+\\/Version[^\\/]{1,255}\\.php$#i',
			\RegexIterator::GET_MATCH);

		$files = array_keys(iterator_to_array($iterator));
		uasort($files, function ($a, $b) {
			return (basename($a) < basename($b)) ? -1 : 1;
		});

		$migrations = [];

		foreach ($files as $file) {
			static::requireOnce($file);
			$className = basename($file, '.php');
			$version = (string) substr($className, 7);
			if ($version === '0') {
				throw new \InvalidArgumentException(sprintf(
					'Cannot load a migrations with the name "%s" because it is a reserved number by doctrine migraitons' . PHP_EOL .
					'It\'s used to revert all migrations including the first one.',
					$version
				));
			}
			$migrations[$version] = sprintf('%s\\%s', $namespace, $className);
		}

		return $migrations;
	}

	public function getMigrationsToExecute($to) {
		$knownMigrations = $this->getMigratedVersions();
		$availableMigrations = $this->getAvailableVersions();

		$toBeExecuted = [];
		foreach ($availableMigrations as $v => $m) {
			if ($to !== 'latest' && $v > $to) {
				continue;
			}
			if ($this->shallBeExecuted($v, $knownMigrations)) {
				$toBeExecuted[$v] = $m;
			}
		}

		return $toBeExecuted;
	}

	private function shallBeExecuted($m, $knownMigrations) {
		if (in_array($m, $knownMigrations)) {
			return false;
		}

		return true;
	}

	public function markAsExecuted($version) {
		$this->connection->insertIfNotExist('*PREFIX*migrations', [
			'app' => $this->appName,
			'version' => $version
		]);
	}

	public function getMigrationsTableName() {
		return $this->connection->getPrefix() . 'migrations';
	}

	public function getMigrationsNamespace() {
		return $this->migrationsNamespace;
	}

	public function getMigrationsDirectory() {
		return $this->migrationsPath;
	}

	public function getMigration($alias) {
		switch($alias) {
			case 'current':
				return $this->getCurrentVersion();
			case 'next':
				return $this->getRelativeVersion($this->getCurrentVersion(), 1);
			case 'prev':
				return $this->getRelativeVersion($this->getCurrentVersion(), -1);
			case 'latest':
				if (empty($this->migrations)) {
					$this->migrations = $this->findMigrations($this->migrationsPath, $this->migrationsNamespace);
				}

				return end(array_keys($this->migrations));
		}
		return '0';
	}

	public function getRelativeVersion($version, $delta) {
		if (empty($this->migrations)) {
			$this->migrations = $this->findMigrations($this->migrationsPath, $this->migrationsNamespace);
		}

		$versions = array_keys($this->migrations);
		array_unshift($versions, 0);
		$offset = array_search($version, $versions);
		if ($offset === false || !isset($versions[$offset + $delta])) {
			// Unknown version or delta out of bounds.
			return null;
		}

		return (string) $versions[$offset + $delta];
	}

	/**
	 * @return mixed|string
	 */
	private function getCurrentVersion() {
		$m = $this->getMigratedVersions();
		if (count($m) === 0) {
			return '0';
		}
		return end(array_values($m));
	}

	public function getClass($version) {
		if (empty($this->migrations)) {
			$this->migrations = $this->findMigrations($this->migrationsPath, $this->migrationsNamespace);
		}

		if (isset($this->migrations[$version])) {
			return $this->migrations[$version];
		}

		throw new \InvalidArgumentException("Version $version is unknown.");
	}

	public function getOutput() {
		return $this->output;
	}

	public function setOutput(IOutput $output) {
		$this->output = $output;
	}
}
