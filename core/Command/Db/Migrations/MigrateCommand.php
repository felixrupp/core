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


use OC\DB\MigrationService;
use OCP\IConfig;
use OCP\IDBConnection;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class MigrateCommand extends Command {

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
			->setName('migrations:migrate')
			->setDescription('Execute a migration to a specified version or the latest available version.')
			->addArgument('app', InputArgument::REQUIRED, 'Name of the app this migration command shall work on')
			->addArgument('version', InputArgument::OPTIONAL, 'The version number (YYYYMMDDHHMMSS) or alias (first, prev, next, latest) to migrate to.', 'latest');

		parent::configure();
	}

	public function execute(InputInterface $input, OutputInterface $output) {
		$appName = $input->getArgument('app');
		$ms = new MigrationService();
		$mc = $ms->buildConfiguration($appName, $this->ocConnection);
		$version = $input->getArgument('version');

		$ms->migrate($mc, $version);
	}

}
