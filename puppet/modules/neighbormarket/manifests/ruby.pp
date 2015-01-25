class neighbormarket::ruby (
  $version = '2.2.0'
) {
	class { 'rbenv': }
	rbenv::plugin { [ 'sstephenson/ruby-build', 'sstephenson/rbenv-gem-rehash' ]: }
	rbenv::build { "${version}": global => true }
	rbenv::gem { 'backup': ruby_version => "${version}" }
	rbenv::gem { 'whenever': ruby_version => "${version}" }
}
