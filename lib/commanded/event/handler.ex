defmodule Commanded.Event.Handler do
  use GenServer
  require Logger

  alias Commanded.Event.Handler
  alias Commanded.Event.Serializer

  defstruct handler_name: nil, handler_module: nil, last_seen_event_id: nil

  def start_link(handler_name, handler_module) do
    GenServer.start_link(__MODULE__, %Handler{
      handler_name: handler_name,
      handler_module: handler_module
    })
  end

  def init(%Handler{} = state) do
    GenServer.cast(self, {:subscribe_to_events})
    {:ok, state}
  end

  def handle_cast({:subscribe_to_events}, %Handler{handler_name: handler_name} = state) do
    {:ok, _} = EventStore.subscribe_to_all_streams(handler_name, self)
    {:noreply, state}
  end

  def handle_info({:events, events}, state) do
    Logger.debug(fn -> "event handler received events: #{inspect events}" end)

    events
    |> Enum.each(fn event -> handle_event(event, state) end)

    state = %Handler{state | last_seen_event_id: List.last(events).event_id}

    {:noreply, state}
  end

  # ignore already seen events
  defp handle_event(%EventStore.RecordedEvent{event_id: event_id} = event, %Handler{last_seen_event_id: last_seen_event_id}) when not is_nil(last_seen_event_id) and event_id <= last_seen_event_id do
    Logger.debug(fn -> "event handler has already seen event: #{inspect event}" end)
  end

  defp handle_event(%EventStore.RecordedEvent{data: data} = event, %Handler{handler_module: handler_module}) do
    data
    |> handler_module.handle
  end
end
