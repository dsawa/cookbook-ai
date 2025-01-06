import { ChangeEvent } from "react";

interface Props {
  value: string;
  disabled?: boolean;
  onChange: (e: ChangeEvent<HTMLTextAreaElement>) => void;
}

export const IngredientTextarea = ({ value, disabled, onChange }: Props) => {
  return (
    <div className="mb-3">
      <label htmlFor="ingredients" className="form-label">
        Enter your ingredients separated by comma in the text area below:
      </label>
      <textarea
        id="ingredients"
        className="form-control"
        value={value}
        onChange={onChange}
        rows={6}
        disabled={disabled}
      />
    </div>
  );
};
