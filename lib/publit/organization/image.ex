defmodule Publit.Organization.Image do
  use PublitWeb, :model
  alias Publit.{Organization}

  @primary_key false
  embedded_schema do
    field :ctype, :string
    field :filename, :string, default: ""
    field :organization_id, :string, virtual: true

    timestamps()
  end

  @ctypes ["list", "logo"]

  def set_image(org, img) do
    o_img = Enum.find(org.images, fn(im) -> im.ctype === img.ctype end) || %Organization.Image{ctype: img.ctype}
    o_img = Map.put(o_img, :organization_id, org.id)

    with %Plug.Upload{} <- img.image,
      {:ok, filename} <- Organization.ImageUploader.store({img.image, o_img}) do
        %Organization.Image{ctype: img.ctype, organization_id: org.id, filename: filename}
    else
      _ -> o_img
    end
  end

end
