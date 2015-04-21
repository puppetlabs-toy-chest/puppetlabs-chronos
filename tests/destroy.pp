chronos_job { 'test1':
  ensure  => 'absent',
  async   => true,
  command => 'echo hi',
  cpus    => 0.1,
  disk    => 256.0,
  epsilon => 'PT30M',
  mem     => 64.0,
  owner   => 'test@example.com',
  retries => 0,
}

chronos_job { 'test2':
  ensure                => absent,
  async                 => true,
  command               => 'echo "this is a test"',
  environment_variables => [ { 'name' => 'TEST_VAR', 'value' => 7 } ],
  owner                 => 'test@example.com',
  retries               => 0,
}
