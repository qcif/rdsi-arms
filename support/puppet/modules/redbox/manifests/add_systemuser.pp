define redbox::add_systemuser($username=$title, $shell='/bin/bash') {

  user { $username:
    ensure     => present,
    home       => "/home/$username",
    shell      => $shell,
    system     => true,
    managehome => true,
  }                                    
}
