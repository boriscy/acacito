# http://blog.danielberkompas.com/elixir/security/2015/07/03/encrypting-data-with-ecto.html
defmodule Publit.AES do
  # Encrypts each plaintext with a different, random IV. This is much more
  # secure than reusing the same IV, and is highly recommended.
  def encrypt(plaintext) do
    iv    = :crypto.strong_rand_bytes(16)
    state = :crypto.stream_init(:aes_ctr, key(), iv)

    {_state, ciphertext} = :crypto.stream_encrypt(state, to_string(plaintext))
    iv <> ciphertext |> Base.encode64()
  end

  # Split the IV that was used off the front of the binary. It's the first
  # 16 bytes.
  def decrypt(txt) do
    {:ok, ctext} = Base.decode64(txt)
    <<iv::binary-16, ciphertext::binary>> = ctext
    state = :crypto.stream_init(:aes_ctr, key, iv)

    {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
    plaintext
  end

  # Convenience function to get the application's configuration key.
  def key do
    :crypto.hash(:sha256, System.get_env("CRYPTO_KEY"))
  end
end
