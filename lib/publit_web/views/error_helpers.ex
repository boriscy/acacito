defmodule PublitWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error message.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    if error = form.source.errors[field] do
      error = elem(error, 0)
      content_tag :span, translate_error({error, []}), class: "help-block"
    end
  end

  def has_error(form, field) do
    if form.source.errors[field] do
      "has-error"
    end
  end

  # Because error message were defined within Ecto, we must
  # call the Gettext module passing our Gettext backend. We
  # also use the "errors" domain as translations are placed
  # in the errors.po file.
  # Ecto will pass the :count keyword if the error message is
  # meant to be pluralized.
  # On your own code and templates, depending on whether you
  # need the message to be pluralized or not, this could be
  # written simply as:
  #
  #     dngettext "errors", "1 file", "%{count} files", count
  #     dgettext "errors", "is invalid"
  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(PublitWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(PublitWeb.Gettext, "errors", msg, opts)
    end
  end

  def get_errors(cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      translate_error({msg, opts})
    end)
  end


    #Enum.map(cs.errors, fn({k, v}) ->
    #  msg = translate_error({elem(v, 0), elem(v, 1)})
    #  {k, msg}
    #end) |> Enum.into(%{})
end
