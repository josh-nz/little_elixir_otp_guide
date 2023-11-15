defmodule Metex.Worker do
  def temperature_of(location) do
    result =
      url_for(location)
      |> Req.get()
      |> parse_response()

    case result do
      {:ok, temp} ->
        "#{location}: #{temp}°C"
      :error ->
        "#{location} not found"
    end
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
end
