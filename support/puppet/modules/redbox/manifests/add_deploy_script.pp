class redbox::add_deploy_script(
  $script_name='deploy.sh',
  $archive_extension='tar.gz',
  $new_extension = "timestamp.new",
  $old_extension = "timestamp.old",
  $deploy_parent_directory="/opt/deploy",
  $install_parent_directory="/opt",
  $owner="redbox",
  $archives,
  $is_using_dns=true,
) {
 
  $working_directory="/home/${owner}"
  $deploy_script_path="${working_directory}/${script_name}"
  
	concat { $deploy_script_path:
		mode  => '0755',
		owner => $owner,
		group => $owner,
	}
	
	concat::fragment { "deploy_main":
		target  => $deploy_script_path,
		content => template("redbox/deploy_main.sh.erb"),
		order   => '01',
	}
	
	redbox::add_archive{$archives:
	 deploy_script_path => $deploy_script_path,
	}
	->
  exec {"$deploy_script_path":
      cwd   => $working_directory,
      user  => $owner,
      tries => 3,
      try_sleep => 3,
      logoutput => true,
   }

}
