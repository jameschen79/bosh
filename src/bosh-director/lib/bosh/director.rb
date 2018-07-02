module Bosh
  module Director
  end
end

require 'digest/sha1'
require 'erb'
require 'fileutils'
require 'forwardable'
require 'logger'
require 'logging'
require 'monitor'
require 'optparse'
require 'ostruct'
require 'pathname'
require 'pp'
require 'tmpdir'
require 'yaml'
require 'time'
require 'zlib'
require 'ipaddr'

require 'common/exec'
require 'bosh/template/evaluation_context'
require 'common/version/release_version_list'

require 'bcrypt'
require 'eventmachine'
require 'netaddr'
require 'delayed_job'
require 'sequel'
require 'sinatra/base'
require 'securerandom'
require 'nats/client'
require 'securerandom'
require 'delayed_job_sequel'

require 'common/thread_formatter'
require 'bosh/director/cloud_factory'
require 'bosh/director/az_cloud_factory.rb'
require 'bosh/director/api'
require 'bosh/director/dns/local_dns_repo'
require 'bosh/director/dns/blobstore_dns_publisher'
require 'bosh/director/dns/canonicalizer'
require 'bosh/director/dns/dns_name_generator'
require 'bosh/director/dns/director_dns_state_updater'
require 'bosh/director/dns/dns_version_converger'
require 'bosh/director/dns/dns_encoder'
require 'bosh/director/dns/local_dns_encoder_manager'
require 'bosh/director/dns/local_dns_manager'
require 'bosh/director/dns/power_dns_manager'
require 'bosh/director/dns/dns_records'
require 'bosh/director/errors'
require 'bosh/director/ext'
require 'bosh/director/ip_util'
require 'bosh/director/cidr_range_combiner'
require 'bosh/director/lock_helper'
require 'bosh/director/validation_helper'
require 'bosh/director/download_helper'
require 'bosh/director/formatter_helper'
require 'bosh/director/tagged_logger'
require 'bosh/director/legacy_deployment_helper'
require 'bosh/director/duplicate_detector'

require 'bosh/director/version'
require 'bosh/director/config'
require 'bosh/director/event_log'
require 'bosh/director/task_db_writer'
require 'bosh/director/task_appender'
require 'bosh/director/blob_util'

require 'bosh/director/digest/bosh_digest'

require 'bosh/director/agent_client'
require 'cloud'
require 'cloud/external_cpi'
require 'cloud/errors'
require 'bosh/director/compile_task'
require 'bosh/director/key_generator'
require 'bosh/director/package_dependencies_manager'

require 'bosh/director/job_renderer'
require 'bosh/director/rendered_templates_persister'

require 'bosh/director/cycle_helper'
require 'bosh/director/worker'
require 'bosh/director/password_helper'
require 'bosh/director/vm_creator'
require 'bosh/director/vm_deleter'
require 'bosh/director/orphaned_vm_deleter'
require 'bosh/director/metadata_updater'
require 'bosh/director/instance_reuser'
require 'bosh/director/deployment_plan'
require 'bosh/director/deployment_plan/variables_parser'
require 'bosh/director/deployment_plan/variables'
require 'bosh/director/deployment_plan/deployment_features_parser'
require 'bosh/director/deployment_plan/deployment_features'
require 'bosh/director/runtime_config'
require 'bosh/director/cloud_config'
require 'bosh/director/cpi_config'
require 'bosh/director/compiled_release'
require 'bosh/director/errand'
require 'bosh/director/duration'
require 'bosh/director/hash_string_vals'
require 'bosh/director/instance_deleter'
require 'bosh/director/instance_updater'
require 'bosh/director/instance_updater/instance_state'
require 'bosh/director/instance_updater/recreate_handler'
require 'bosh/director/instance_updater/state_applier'
require 'bosh/director/instance_updater/update_procedure'
require 'bosh/director/disk_manager'
require 'bosh/director/orphan_disk_manager'
require 'bosh/director/stopper'
require 'bosh/director/job_runner'
require 'bosh/director/instance_group_updater'
require 'bosh/director/instance_group_updater_factory'
require 'bosh/director/job_queue'
require 'bosh/director/lock'
require 'bosh/director/nats_rpc'
require 'bosh/director/network_reservation'
require 'bosh/director/problem_scanner/scanner'
require 'bosh/director/problem_resolver'
require 'bosh/director/post_deployment_script_runner'
require 'bosh/director/error_ignorer'
require 'bosh/director/deployment_deleter'
require 'bosh/director/permission_authorizer'
require 'bosh/director/transactor'
require 'bosh/director/sequel'
require 'bosh/director/agent_broadcaster'
require 'bosh/director/timeout'
require 'bosh/director/nats_client_cert_generator'
require 'common/thread_pool'

require 'bosh/director/config_server/deep_hash_replacement'
require 'bosh/director/config_server/uaa_auth_provider'
require 'bosh/director/config_server/auth_http_client'
require 'bosh/director/config_server/retryable_http_client'
require 'bosh/director/config_server/config_server_http_client'
require 'bosh/director/config_server/client'
require 'bosh/director/config_server/client_factory'
require 'bosh/director/config_server/variables_interpolator'
require 'bosh/director/config_server/config_server_helper'

require 'bosh/director/links/links_manager'
require 'bosh/director/links/links_error_builder'
require 'bosh/director/links/links_parser'

require 'bosh/director/disk/persistent_disk_comparators'

require 'bosh/director/manifest/manifest'
require 'bosh/director/manifest/changeset'
require 'bosh/director/manifest/redactor'
require 'bosh/director/manifest/diff_lines'

require 'bosh/director/log_bundles_cleaner'
require 'bosh/director/logs_fetcher'

require 'bosh/director/cloudcheck_helper'
require 'bosh/director/problem_handlers/base'
require 'bosh/director/problem_handlers/invalid_problem'
require 'bosh/director/problem_handlers/inactive_disk'
require 'bosh/director/problem_handlers/missing_disk'
require 'bosh/director/problem_handlers/unresponsive_agent'
require 'bosh/director/problem_handlers/mount_info_mismatch'
require 'bosh/director/problem_handlers/missing_vm'

require 'bosh/director/jobs/base_job'
require 'bosh/director/jobs/backup'
require 'bosh/director/jobs/scheduled_backup'
require 'bosh/director/jobs/scheduled_orphaned_disk_cleanup'
require 'bosh/director/jobs/scheduled_orphaned_vm_cleanup'
require 'bosh/director/jobs/scheduled_events_cleanup'
require 'bosh/director/jobs/scheduled_dns_blobs_cleanup'
require 'bosh/director/jobs/create_snapshot'
require 'bosh/director/jobs/snapshot_deployment'
require 'bosh/director/jobs/snapshot_deployments'
require 'bosh/director/jobs/snapshot_self'
require 'bosh/director/jobs/delete_deployment'
require 'bosh/director/jobs/delete_deployment_snapshots'
require 'bosh/director/jobs/delete_release'
require 'bosh/director/jobs/delete_snapshots'
require 'bosh/director/jobs/delete_orphan_disks'
require 'bosh/director/jobs/delete_stemcell'
require 'bosh/director/jobs/cleanup_artifacts'
require 'bosh/director/jobs/export_release'
require 'bosh/director/jobs/update_deployment'
require 'bosh/director/jobs/update_release'
require 'bosh/director/jobs/update_stemcell'
require 'bosh/director/jobs/fetch_logs'
require 'bosh/director/jobs/vm_state'
require 'bosh/director/jobs/run_errand'
require 'bosh/director/jobs/cloud_check/scan'
require 'bosh/director/jobs/cloud_check/scan_and_fix'
require 'bosh/director/jobs/cloud_check/apply_resolutions'
require 'bosh/director/jobs/release/release_job'
require 'bosh/director/jobs/ssh'
require 'bosh/director/jobs/attach_disk'
require 'bosh/director/jobs/delete_vm'
require 'bosh/director/jobs/helpers'
require 'bosh/director/jobs/db_job'
require 'bosh/director/jobs/orphan_disk'

require 'bosh/director/models/helpers/model_helper'

require 'bosh/director/db_backup'
require 'bosh/director/blobstores'
require 'bosh/director/api/director_uuid_provider'
require 'bosh/director/api/local_identity_provider'
require 'bosh/director/api/uaa_identity_provider'
require 'bosh/director/api/event_manager'
require 'bosh/director/app'

module Bosh::Director
  autoload :Models, 'bosh/director/models' # Defining model classes relies on a database connection
end

require 'bosh/director/thread_pool'
require 'bosh/director/api/extensions/scoping'
require 'bosh/director/api/extensions/syslog_request_logger'
require 'bosh/director/api/controllers/backups_controller'
require 'bosh/director/api/controllers/cleanup_controller'
require 'bosh/director/api/controllers/deployments_controller'
require 'bosh/director/api/controllers/disks_controller'
require 'bosh/director/api/controllers/orphan_disks_controller'
require 'bosh/director/api/controllers/orphaned_vms_controller'
require 'bosh/director/api/controllers/packages_controller'
require 'bosh/director/api/controllers/info_controller'
require 'bosh/director/api/controllers/jobs_controller'
require 'bosh/director/api/controllers/releases_controller'
require 'bosh/director/api/controllers/resources_controller'
require 'bosh/director/api/controllers/resurrection_controller'
require 'bosh/director/api/controllers/stemcells_controller'
require 'bosh/director/api/controllers/stemcell_uploads_controller'
require 'bosh/director/api/controllers/tasks_controller'
require 'bosh/director/api/controllers/task_controller'
require 'bosh/director/api/controllers/configs_controller'
require 'bosh/director/api/controllers/deployment_configs_controller'
require 'bosh/director/api/controllers/cloud_configs_controller'
require 'bosh/director/api/controllers/runtime_configs_controller'
require 'bosh/director/api/controllers/cpi_configs_controller'
require 'bosh/director/api/controllers/locks_controller'
require 'bosh/director/api/controllers/restore_controller'
require 'bosh/director/api/controllers/events_controller'
require 'bosh/director/api/controllers/vms_controller'
require 'bosh/director/api/controllers/link_providers_controller'
require 'bosh/director/api/controllers/link_consumers_controller'
require 'bosh/director/api/controllers/links_controller'
require 'bosh/director/api/controllers/link_address_controller'
require 'bosh/director/api/route_configuration'

require 'bosh/director/step_executor'

require 'common/common'

require 'bosh/blobstore_client/errors'
require 'bosh/blobstore_client/client'

Bosh::Blobstore.autoload(:BaseClient, 'bosh/blobstore_client/base')
require 'bosh/blobstore_client/retryable_blobstore_client'
require 'bosh/blobstore_client/sha1_verifiable_blobstore_client'

Bosh::Blobstore.autoload(:SimpleBlobstoreClient, 'bosh/blobstore_client/simple_blobstore_client')
Bosh::Blobstore.autoload(:LocalClient, 'bosh/blobstore_client/local_client')
Bosh::Blobstore.autoload(:DavcliBlobstoreClient, 'bosh/blobstore_client/davcli_blobstore_client')
Bosh::Blobstore.autoload(:S3cliBlobstoreClient, 'bosh/blobstore_client/s3cli_blobstore_client')
Bosh::Blobstore.autoload(:GcscliBlobstoreClient, 'bosh/blobstore_client/gcscli_blobstore_client')
