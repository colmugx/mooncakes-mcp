///|
/// Cache entry with expiration time
pub struct CacheEntry[V] {
  value : V
  expires_at : Int64
}

///|
/// Generic cache with TTL support
pub struct Cache[K, V] {
  map : Map[K, CacheEntry[V]]
  time_source : &TimeSource
}

///|
/// Create a new cache instance
pub fn[K, V] Cache::new(ts : &TimeSource) -> Cache[K, V] {
  { map: Map::new(), time_source: ts }
}

///|
/// Get value from cache, returns None if expired or not found
pub fn[K : Hash + Eq, V] Cache::get(self : Cache[K, V], key : K) -> V? {
  match self.map.get(key) {
    Some(entry) =>
      if entry.expires_at > self.time_source.now() {
        Some(entry.value)
      } else {
        self.map.remove(key)
        None
      }
    None => None
  }
}

///|
/// Set value in cache with TTL (time to live) in seconds
pub fn[K : Hash + Eq, V] Cache::set(
  self : Cache[K, V],
  key : K,
  value : V,
  ttl : Int,
) -> Unit {
  let expires_at = self.time_source.now() + ttl.to_int64()
  self.map.set(key, { value, expires_at })
}

///|
/// Clear all entries from cache
pub fn[K, V] Cache::clear(self : Cache[K, V]) -> Unit {
  self.map.clear()
}
