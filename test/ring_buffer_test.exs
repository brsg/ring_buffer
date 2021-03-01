defmodule RingBufferTest do
  use ExUnit.Case
  doctest RingBuffer

  alias RingBuffer

  test "new/1 initializes buffer correctly" do
    assert %RingBuffer{} = under_test = RingBuffer.new(9)
    assert 9 = under_test.max_size
    assert 0 = under_test.size
    assert 0 = :queue.len(under_test.queue)
  end

  test "put/2 for non-full buffer adds item, increments size and returns nil for dropped" do
    assert %RingBuffer{} = original = RingBuffer.new(3)
    under_test = RingBuffer.put(original, "yellow")
    assert 1 = under_test.size
    assert nil == under_test.evicted
    assert "yellow" == :queue.get(under_test.queue)
  end

  test "put/2 for full buffer adds item, maintains max size and drops/returns oldest item" do
    assert %RingBuffer{} = under_test = RingBuffer.new(3)
    |> RingBuffer.put("one")
    |> RingBuffer.put("two")
    |> RingBuffer.put("three")
    assert under_test.size == under_test.max_size

    under_test = RingBuffer.put(under_test, "four")
    assert "one" == under_test.evicted
    assert 3 = under_test.size
    assert "two" == :queue.get(under_test.queue)
  end

  test "take/1 returns oldest item" do
    assert %RingBuffer{} = under_test = RingBuffer.new(2)
    |> RingBuffer.put(100)
    |> RingBuffer.put(200)
    assert under_test.size == under_test.max_size

    {taken, new_buffer} = RingBuffer.take(under_test)
    assert 100 == taken
    assert new_buffer.size == new_buffer.max_size - 1
  end

  test "oldest/1 returns oldest item" do
    assert %RingBuffer{} = b0 = RingBuffer.new(2)
    assert nil == RingBuffer.oldest(b0)
    b1 = RingBuffer.put(b0, "111")
    assert "111" = RingBuffer.oldest(b1)
    b2 = RingBuffer.put(b1, "222")
    assert "111" = RingBuffer.oldest(b2)
    b3 = RingBuffer.put(b2, "333")
    assert "222" = RingBuffer.oldest(b3)
    b4 = RingBuffer.put(b3, "444")
    assert "333" = RingBuffer.oldest(b4)
    b5 = RingBuffer.put(b4, "555")
    assert "444" = RingBuffer.oldest(b5)
  end

  test "newest/1 returns newest item" do
    assert %RingBuffer{} = b0 = RingBuffer.new(2)
    assert nil == RingBuffer.newest(b0)
    b1 = RingBuffer.put(b0, "111")
    assert "111" = RingBuffer.newest(b1)
    b2 = RingBuffer.put(b1, "222")
    assert "222" = RingBuffer.newest(b2)
    b3 = RingBuffer.put(b2, "333")
    assert "333" = RingBuffer.newest(b3)
    b4 = RingBuffer.put(b3, "444")
    assert "444" = RingBuffer.newest(b4)
    b5 = RingBuffer.put(b4, "555")
    assert "555" = RingBuffer.newest(b5)
  end

end
