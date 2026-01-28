///|
/// Application context holding all caches
pub struct AppContext {
  modules_cache : Cache[String, Array[@client.ModuleInfo]]
  package_cache : Cache[String, @client.PackageResource]
  index_cache : Cache[String, @client.ModuleIndex]
  data_cache : Cache[String, Array[@client.SymbolInfo]]
}

///|
/// Create a new application context with initialized caches
pub fn AppContext::new() -> AppContext {
  let ts = RealTimeSource::{  }
  {
    modules_cache: Cache::new(ts),
    package_cache: Cache::new(ts),
    index_cache: Cache::new(ts),
    data_cache: Cache::new(ts),
  }
}

///|
/// Clear all caches in the context
pub fn AppContext::clear_all(self : AppContext) -> Unit {
  self.modules_cache.clear()
  self.package_cache.clear()
  self.index_cache.clear()
  self.data_cache.clear()
}

///|
/// Get modules from cache
pub fn AppContext::get_modules(
  self : AppContext,
  key : String,
) -> Array[@client.ModuleInfo]? {
  self.modules_cache.get(key)
}

///|
/// Set modules in cache with TTL (5 minutes)
pub fn AppContext::set_modules(
  self : AppContext,
  key : String,
  value : Array[@client.ModuleInfo],
) -> Unit {
  self.modules_cache.set(key, value, 300)
}

///|
/// Get package from cache
pub fn AppContext::get_package(
  self : AppContext,
  key : String,
) -> @client.PackageResource? {
  self.package_cache.get(key)
}

///|
/// Set package in cache with TTL (10 minutes)
pub fn AppContext::set_package(
  self : AppContext,
  key : String,
  value : @client.PackageResource,
) -> Unit {
  self.package_cache.set(key, value, 600)
}

///|
/// Get index from cache
pub fn AppContext::get_index(
  self : AppContext,
  key : String,
) -> @client.ModuleIndex? {
  self.index_cache.get(key)
}

///|
/// Set index in cache with TTL (10 minutes)
pub fn AppContext::set_index(
  self : AppContext,
  key : String,
  value : @client.ModuleIndex,
) -> Unit {
  self.index_cache.set(key, value, 600)
}

///|
/// Get data from cache
pub fn AppContext::get_data(
  self : AppContext,
  key : String,
) -> Array[@client.SymbolInfo]? {
  self.data_cache.get(key)
}

///|
/// Set data in cache with TTL (10 minutes)
pub fn AppContext::set_data(
  self : AppContext,
  key : String,
  value : Array[@client.SymbolInfo],
) -> Unit {
  self.data_cache.set(key, value, 600)
}

///|
/// Generate cache warning message for agents
pub fn cache_warning() -> String {
  "WARNING: Results from cache (may be stale). Call 'clear_cache' tool to fetch fresh data from network."
}
