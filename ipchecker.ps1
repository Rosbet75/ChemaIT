docker ps -q | ForEach-Object {
  $inspect = docker inspect $_ | ConvertFrom-Json
  $name = $inspect[0].Name.TrimStart('/')
  $networks = $inspect[0].NetworkSettings.Networks.GetEnumerator()
  foreach ($net in $networks) {
    "$name - $($net.Key): $($net.Value.IPAddress)"
  }
}
