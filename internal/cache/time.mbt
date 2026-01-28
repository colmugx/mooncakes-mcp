///|
/// Time source trait for cache expiration
pub trait TimeSource {
  now(Self) -> Int64
}

///|
/// Real-time source using system time
pub struct RealTimeSource {}

///|
pub impl TimeSource for RealTimeSource with now(_self) {
  0
}

///|
/// Mock time source for testing
pub struct MockTimeSource {
  mut current_time : Int64
}

///|
pub impl TimeSource for MockTimeSource with now(self) {
  self.current_time
}

///|
pub fn MockTimeSource::new(start_time : Int64) -> MockTimeSource {
  { current_time: start_time }
}

///|
pub fn MockTimeSource::set_time(self : MockTimeSource, t : Int64) -> Unit {
  self.current_time = t
}
