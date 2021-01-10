defmodule Bliss.Validators.Any do
  @pre_spec_keys [
    :allow,
    :invalid,
    :valid
  ]

  @spec_keys [
    :optional,
    :required
  ]

  alias Bliss.ValidationError

  def validate(value, spec, opts \\ [], label \\ "value") do
    case _validate(value, spec, opts, label) do
      {:error, error} -> {:error, error}
      {status, value, _, _} -> {status, value}
    end
  end

  def _validate(value, spec, opts, label) do
    {value, spec} = value_or_default(value, spec)

    case pre_validate(value, spec, opts, label) do
      {:error, error} -> {:error, error}
      {:ok, value, spec, :halt} -> {:ok, value, spec, :halt}
      {:ok, value, spec, :cont} -> validate_specs(@spec_keys, value, spec, opts, label)
    end
  end

  defp value_or_default(value, spec) do
    {default, spec} = Keyword.pop(spec, :default)

    if value == nil do
      {default, spec}
    else
      {value, spec}
    end
  end

  defp pre_validate(value, spec, opts, label) do
    validate_specs(@pre_spec_keys, value, spec, opts, label)
  end

  defp validate_specs(specs, value, spec, opts, label) do
    Enum.reduce_while(spec, {:ok, value, spec, :cont}, fn
      {k, _}, _ ->
        if k not in specs do
          {:cont, {:ok, value, spec, :cont}}
        else
          {args, spec} = Keyword.pop!(spec, k)

          case do_validation(value, k, args, opts, label) do
            {:error, error} -> {:halt, {:error, error}}
            {:ok, value, :halt} -> {:halt, {:ok, value, spec, :halt}}
            {:ok, value, :cont} -> {:cont, {:ok, value, spec, :cont}}
          end
        end
    end)
  end

  defp do_validation(value, :allow, args, _opts, _label) do
    if value in args do
      {:ok, value, :halt}
    else
      {:ok, value, :cont}
    end
  end

  defp do_validation(value, :valid, args, _opts, label) do
    if value in args do
      {:ok, value, :halt}
    else
      {:error, %ValidationError{message: "`#{label}` must be one of #{inspect(args)}"}}
    end
  end

  defp do_validation(value, :invalid, args, _opts, label) do
    if value in args do
      {:error, %ValidationError{message: "`#{label}` contains an invalid value"}}
    else
      {:ok, value, :cont}
    end
  end

  defp do_validation(value, :optional, true, _opts, _label) do
    {:ok, value, :cont}
  end

  defp do_validation(value, :optional, false, _opts, label) do
    if value == nil do
      {:error, %ValidationError{message: "`#{label}` is required"}}
    else
      {:ok, value, :cont}
    end
  end

  defp do_validation(value, :required, true, _opts, label) do
    if value == nil do
      {:error, %ValidationError{message: "`#{label}` is required"}}
    else
      {:ok, value, :cont}
    end
  end

  defp do_validation(value, :required, false, _opts, _label) do
    {:ok, value, :cont}
  end
end
