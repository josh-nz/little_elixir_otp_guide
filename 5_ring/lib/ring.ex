defmodule Ring do
  def create_processes(n) do
    1..n
    |> Enum.map(fn _ -> spawn(fn -> loop() end) end)
  end

  def loop() do
    receive do
      {:link, link_to} when is_pid(link_to) ->
        Process.link(link_to)
        loop()

      :crash ->
        1/0
    end
  end

  def link_processes(procs) do
    link_processes(procs, [])
  end

  def link_processes([a, b | rest], linked_processes) do
    send(a, {:link, b})
    link_processes([b | rest], [a | linked_processes])
  end

  def link_processes([a | []], linked_processes) do
    first_process = linked_processes |> List.last()
    send(a, {:link, first_process})
    :ok
  end
end
