define redbox::add_systemuser($username=$title, $shell='/bin/sh') {

user { $username:
    ensure     => present,
    home       => "/home/$username",
    shell      => $shell,
    system     => true,
    managehome => true,
  }                                    
}
