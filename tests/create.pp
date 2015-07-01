
chronos_job { 'test1':
  ensure  => 'present',
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
  ensure                => 'present',
  async                 => true,
  command               => 'echo "this is a test"',
  environment_variables => { 'TEST_VAR' => 7 },
  owner                 => 'test@example.com',
  retries               => 0,
}
