///|
test "cache_hit" {
  let mock = MockTimeSource::new(0)
  let cache : Cache[String, Int] = Cache::new(mock)
  cache.set("key", 42, 100)
  let result = cache.get("key")
  inspect(result, content="Some(42)")
}

///|
test "cache_expired" {
  let mock = MockTimeSource::new(0)
  let cache : Cache[String, Int] = Cache::new(mock)
  cache.set("key", 42, 100) // expires at 100
  mock.set_time(200) // advance time past expiration
  let result = cache.get("key")
  inspect(result, content="None")
}

///|
test "cache_miss" {
  let mock = MockTimeSource::new(0)
  let cache : Cache[String, Int] = Cache::new(mock)
  let result = cache.get("nonexistent")
  inspect(result, content="None")
}

///|
test "cache_clear" {
  let mock = MockTimeSource::new(0)
  let cache : Cache[String, Int] = Cache::new(mock)
  cache.set("key1", 42, 100)
  cache.set("key2", 43, 100)
  cache.clear()
  let result1 = cache.get("key1")
  let result2 = cache.get("key2")
  inspect(result1, content="None")
  inspect(result2, content="None")
}
