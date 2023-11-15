defmodule Metex.Worker do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_temperature(pid, location) do
    GenServer.call(pid, {:location, location})
  end

  def get_stats(pid) do
    GenServer.call(pid, :get_stats)
  end

  def reset_stats(pid) do
    GenServer.cast(pid, :reset_stats)
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  # Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temp} ->
        new_stats = update_stats(stats, location)
        {:reply, "#{temp}°C", new_stats}

      _ ->
        {:reply, :error, stats}
    end
  end

  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  @impl true
  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    # This message will cause GenServer to call the terminate/2 callback.
    # It is not guaranteed that terminate/2 will be called when a GenServer
    # stops however, see the terminate/2 docs for more details.
    {:stop, :normal, stats}
  end

  @impl true
  def handle_info(msg, stats) do
    IO.puts("Received #{msg}")
    {:noreply, stats}
  end

  @impl true
  def terminate(reason, _stats) do
    IO.puts "Server terminated because of #{reason}."
    :ok
  end

  # Helper functions

  defp temperature_of(location) do
    url_for(location)
    |> Req.get()
    |> parse_response()
  end

  defp url_for(location) do
    location = URI.encode(location)
    "https://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key()}"
  end

  defp parse_response({:ok, %Req.Response{body: body}}) do
    body |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15 |> Float.round(1))
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp api_key() do
    Application.fetch_env!(:metex, :api_key)
  end

  defp update_stats(old_stats, location) do
    Map.update(old_stats, location, 1, &(&1 + 1))
  end
end
