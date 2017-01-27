<?php
/**
 * @author Thomas Müller <thomas.mueller@tmit.eu>
 *
 * @copyright Copyright (c) 2016, ownCloud GmbH.
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

namespace OC\Core\Command\Db\Migrations;

use OC\DB\MigrationConfiguration;
use OC\DB\MigrationService;
use OCP\IConfig;
use OCP\IDBConnection;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class StatusCommand extends Command {

	/** @var IDBConnection */
	private $ocConnection;

	/**
	 * @param \OCP\IConfig $config
	 */
	public function __construct(IConfig $config, IDBConnection $connection) {
		$this->config = $config;
		$this->ocConnection = $connection;
		parent::__construct();
	}

	protected function configure() {
		$this
			->setName('migrations:status')
			->setDescription('View the status of a set of migrations.')
			->addArgument('app', InputArgument::REQUIRED, 'Name of the app this migration command shall work on');
	}

	public function execute(InputInterface $input, OutputInterface $output) {
		$appName = $input->getArgument('app');
		$ms = new MigrationService();
		$mc = $ms->buildConfiguration($appName, $this->ocConnection);

		$infos = $this->getMigrationsInfos($mc);
		foreach ($infos as $key => $value) {
			$output->writeln("    <comment>>></comment> $key: " . str_repeat(' ', 50 - strlen($key)) . $value);
		}
	}

	public function getMigrationsInfos(MigrationConfiguration $configuration) {

		$executedMigrations = $configuration->getMigratedVersions();
		$availableMigrations = $configuration->getAvailableVersions();
		$executedUnavailableMigrations = array_diff($executedMigrations, array_keys($availableMigrations));

		$numExecutedUnavailableMigrations = count($executedUnavailableMigrations);
		$numNewMigrations = count(array_diff(array_keys($availableMigrations), $executedMigrations));

		$infos = [
			'App'								=> $configuration->getApp(),
			'Version Table Name'                => $configuration->getMigrationsTableName(),
			'Migrations Namespace'              => $configuration->getMigrationsNamespace(),
			'Migrations Directory'              => $configuration->getMigrationsDirectory(),
			'Previous Version'                  => $this->getFormattedVersionAlias($configuration, 'prev'),
			'Current Version'                   => $this->getFormattedVersionAlias($configuration, 'current'),
			'Next Version'                      => $this->getFormattedVersionAlias($configuration, 'next'),
			'Latest Version'                    => $this->getFormattedVersionAlias($configuration, 'latest'),
			'Executed Migrations'               => count($executedMigrations),
			'Executed Unavailable Migrations'   => $numExecutedUnavailableMigrations,
			'Available Migrations'              => count($availableMigrations),
			'New Migrations'                    => $numNewMigrations,
		];

		return $infos;
	}

	private function getFormattedVersionAlias(MigrationConfiguration $configuration, $alias) {
		$migration = $configuration->getMigration($alias);
		//No version found
		if ($migration === null) {
			if ($alias === 'next') {
				return 'Already at latest migration step';
			}

			if ($alias === 'prev') {
				return 'Already at first migration step';
			}
		}

		return $migration;
	}


}
