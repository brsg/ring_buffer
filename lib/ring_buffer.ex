defmodule RingBuffer do
  @moduledoc """
  RingBuffer provides an Elixir ring buffer implementation based on Erlang :queue.

  There are other fine Elxir libraries providing implementations of
  ring or circular buffers. This one provides one wanted feature that the
  others did not provide, namely that the item that was evicted due to
  a put/2 call is available for inspection at the end of the put/2 call.
  
  In this implementation, put/2 returns the new RingBuffer to preserve the
  abilty to build pipelines and the item that was evicted as the result of
  the last call to put/2, if any, is available in the field :evicted.
  
  If the :size of the buffer at the time of the last call to put/2 was less
  than the configured :max_size, then :evicted will be nil after the call
  to put/2 since adding the new item did not require evicting another item.

  A call to take/1 will cause :evicted to be set to nil.
  """
  @typedoc """
      Type that represents RingBuffer struct with :maxsize as integer,
      :size as integer, :queue as tuple and :evicted as any
  """
  @type t :: %RingBuffer{max_size: integer, size: integer, queue: tuple, evicted: any}
  alias __MODULE__

  defstruct [:max_size, :size, :queue, :evicted]

  @doc """
  Creates a new RingBuffer struct.

  ## Parameters

    - max_size: the max number of items in the buffer.

  ## Examples

      iex> RingBuffer.new(10)
      %RingBuffer{queue: {[], []}, max_size: 10, size: 0, evicted: nil}
  """
  @spec new(max_size :: integer) :: RingBuffer.t()
  def new(max_size) when is_integer(max_size) and max_size > 0 do
    %RingBuffer{max_size: max_size, size: 0, queue: :queue.new(), evicted: nil}
  end

  @doc """
  Returns true if buffer contains no items.

  ## Parameters

    - buffer: the RingBuffer whose emptiness is to be tested

  ## Examples

      iex> RingBuffer.new(5)
      ...> |> RingBuffer.empty?()
      true

      iex> RingBuffer.new(4)
      ...> |> RingBuffer.put("red")
      ...> |> RingBuffer.empty?()
      false
  """
  @spec empty?(buffer :: RingBuffer.t()) :: boolean
  def empty?(%RingBuffer{} = buffer) do
    :queue.is_empty(buffer.queue)
  end

  @doc """
  Adds the item to the buffer. When buffer :size is less than :max_size, 
  the item will be added, the buffer :size will be incremented by one
  and :evicted will be nil. When bufffer :size is equal to :max_size,
  the item will be added, the buffer :size will remain at :max_size,
  and the oldest item in the buffer preceding the call to put/2 will
  be bound to :evicted.

  ## Parameters

    - buffer: the RingBuffer to which item is to be added
    - item: the item to add to buffer

  ## Examples

      iex> RingBuffer.new(8)
      ...> |> RingBuffer.put("elixir")
      ...> |> RingBuffer.put("is")
      ...> |> RingBuffer.put("the")
      ...> |> RingBuffer.put("best")
      %RingBuffer{queue: {["best", "the", "is"], ["elixir"]}, max_size: 8, size: 4, evicted: nil}

      iex> RingBuffer.new(3)
      ...> |> RingBuffer.put("elixir")
      ...> |> RingBuffer.put("is")
      ...> |> RingBuffer.put("the")
      ...> |> RingBuffer.put("best")
      %RingBuffer{queue: {["best", "the"], ["is"]}, max_size: 3, size: 3, evicted: "elixir"}
  """
  @spec put(buffer :: RingBuffer.t(), item :: any) :: RingBuffer.t()
  def put(%RingBuffer{} = buffer, item) when buffer.size < buffer.max_size do
    new_queue = :queue.in(item, buffer.queue)
    new_size = buffer.size + 1
    %RingBuffer{buffer | queue: new_queue, size: new_size, evicted: nil}
  end

  def put(%RingBuffer{} = buffer, item) when buffer.size == buffer.max_size do
    {{:value, evicted}, new_queue} = :queue.out(buffer.queue)
    new_queue = :queue.in(item, new_queue)
    %RingBuffer{buffer | queue: new_queue, evicted: evicted}
  end

  @doc """
  Takes the oldest item from the buffer, returning a 2-element tuple
  containing the taken item and the new buffer. For a non-empty buffer,
  the taken item will be non-nil and the :size of the buffer will be
  decremented by one. For an empty buffer, the taken item will be nil
  and the :size of the buffer will continue to be zero.

  ## Parameters

    - buffer: the RingBuffer from which an item is to be taken

  ## Examples

      iex> RingBuffer.new(3)
      ...> |> RingBuffer.put("elixir")
      ...> |> RingBuffer.put("is")
      ...> |> RingBuffer.put("the")
      ...> |> RingBuffer.put("best")
      ...> |> RingBuffer.take()
      {"is", %RingBuffer{queue: {["best"], ["the"]}, max_size: 3, size: 2, evicted: nil}}

      iex> RingBuffer.new(3)
      ...> |> RingBuffer.take()
      {nil, %RingBuffer{queue: {[], []}, max_size: 3, size: 0, evicted: nil}}
  """
  @spec take(buffer :: RingBuffer.t()) :: {nil, RingBuffer.t()} | {any, RingBuffer.t()}
  def take(%RingBuffer{} = buffer) when buffer.size > 0 do
    {{:value, taken}, new_queue} = :queue.out(buffer.queue)
    new_size = buffer.size - 1
    {taken, %RingBuffer{buffer | queue: new_queue, size: new_size, evicted: nil}}
  end

  def take(%RingBuffer{} = buffer) when buffer.size == 0 do
    {nil, %RingBuffer{buffer | evicted: nil}}
  end

  @doc """
  Returns the oldest item in the buffer, or nil if the buffer is empty.

  ## Parameters

    - buffer: the RingBuffer whose oldest item is sought

  ## Examples

      iex> RingBuffer.new(3)
      ...> |> RingBuffer.put("elixir")
      ...> |> RingBuffer.put("is")
      ...> |> RingBuffer.put("the")
      ...> |> RingBuffer.put("best")
      ...> |> RingBuffer.oldest()
      "is"

      iex> RingBuffer.new(3)
      ...> |> RingBuffer.oldest()
      nil
  """
  @spec oldest(buffer :: RingBuffer.t()) :: nil | any
  def oldest(%RingBuffer{} = buffer) do
    case :queue.peek(buffer.queue) do
      {:value, item} -> item
      :empty -> nil
    end
  end

  @doc """
  Returns the newest item in the buffer, or nil if the buffer is empty.

  ## Parameters

    - buffer: the RingBuffer whose newest item is sought

  ## Examples

      iex> RingBuffer.new(3)
      ...> |> RingBuffer.put("elixir")
      ...> |> RingBuffer.put("is")
      ...> |> RingBuffer.put("the")
      ...> |> RingBuffer.put("best")
      ...> |> RingBuffer.newest()
      "best"

      iex> RingBuffer.new(3)
      ...> |> RingBuffer.newest()
      nil
  """
  @spec newest(buffer :: RingBuffer.t()) :: nil | any
  def newest(%RingBuffer{} = buffer) do
    case :queue.peek_r(buffer.queue) do
      {:value, item} -> item
      :empty -> nil
    end
  end

end