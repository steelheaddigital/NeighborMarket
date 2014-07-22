class neighbormarket::ruby (
  $version = '2.0.0-p481'
) {
	class { 'rbenv': }
	rbenv::plugin { [ 'sstephenson/ruby-build', 'sstephenson/rbenv-gem-rehash' ]: }
	rbenv::build { "${version}": global => true }
}
