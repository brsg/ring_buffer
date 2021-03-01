# ring_buffer
`RingBuffer` is an implementation of a ring or circular buffer data
structure, internally based on Erlang's :queue.


A `RingBuffer` has a `:max_size` which is specifed at creation via `new/1`.

Calling `put/2` on a `RingBuffer` whose `:size` is less than its `:max_size`
will:
* add the item to the buffer
* increment the `:size` of the buffer
* set `:evicted` to nil (since no item was evicted by the call to `put/2`)

Calling `put/2` on a `RingBuffer` whose `:size` is equal to its `:max_size`
will:
* add the item to the buffer
* maintain `:size` equal to :max_size
* set `:evicted` to the oldest item in the buffer preceding the call to `put/2`

Thus, this implementation offers the ability to access the item that was
evicted from the buffer as the result of the the most recent call
to `put/2` (if any) via the `:evicted` field of the `%RingBuffer{}`
struct.

See the doctests in `RingBuffer.ex` and test cases in `ring_buffer_test.exs`
for examples of using `RingBuffer`.

## License

Copyright 2021 Blue River Systems Group, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
