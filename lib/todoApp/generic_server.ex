defmodule TodoApp.GenericServer do
  # The details of implementation for a specific server will be provided by
  # the CB module itself
  def start(callback_module) do
    spawn(fn ->
      intial_state = callback_module.init()
      loop(callback_module, intial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {request, self()})

    receive do
      {:response, response} ->
        response
    end
  end

  # PRIVATE

  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
    end

    send(caller, {:response, response})

    loop(callback_module, new_state)
  end
end
