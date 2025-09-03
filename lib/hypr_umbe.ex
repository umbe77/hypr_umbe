defmodule HyprUmbe do
  def get_socket2_path() do
    his = System.get_env("HYPRLAND_INSTANCE_SIGNATURE")
    xdg_runtime = System.get_env("XDG_RUNTIME_DIR")
    "#{xdg_runtime}/hypr/#{his}/.socket2.sock"
  end

  def get_socket_path() do
    his = System.get_env("HYPRLAND_INSTANCE_SIGNATURE")
    xdg_runtime = System.get_env("XDG_RUNTIME_DIR")
    "#{xdg_runtime}/hypr/#{his}/.socket.sock"
  end

  def start do
    case :gen_tcp.connect({:local, get_socket2_path()}, 0, [
           :binary,
           packet: :line,
           active: false,
           reuseaddr: true
         ]) do
      {:ok, socket} ->
        IO.puts("Connected to Hyprland")
        loop_rec(socket)

      {:error, reason} ->
        IO.puts("Failed to connect #{inspect(reason)}")
    end
  end

  defp loop_rec(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        IO.puts("Recieved #{data}")
        loop_rec(socket)

      {:error, :closed} ->
        IO.puts("Connection closed")

      {:error, reason} ->
        IO.puts("Failed to connect #{inspect(reason)}")
    end
  end

  def main(_args) do
    start()
  end
end
