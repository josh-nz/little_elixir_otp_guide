defmodule ID3Parser do
  @doc """
  Parses ID3v1 information from a MP3 file.
  Call Path.expand(file) first before passing to this function, to ensure
  a fully expanded path.
  eg ID3Parser.parse(Path.expand("~/Music/music/pitch black/2020 - the light within/03 Third Light (Bodie Remix).mp3"))
  """
  def parse(file_name) do
    case File.read(file_name) do
      {:ok, mp3} ->
        # ID3v1 format.
        mp3_byte_size = byte_size(mp3) - 128
        <<_::binary-size(mp3_byte_size), id3_tag::binary>> = mp3

        <<"TAG", title::binary-size(30), artist::binary-size(30), album::binary-size(30),
          year::binary-size(4), _rest::binary>> = id3_tag

        IO.puts("#{artist} - #{title} (#{album}, #{year})")

      _ ->
        IO.puts("Couldn't open #{file_name}")
    end
  end
end
