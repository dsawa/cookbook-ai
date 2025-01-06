import { FormEvent, useState } from "react";
import { IngredientTextarea } from "./IngredientTextarea";
import { Button } from "./Button";

export const IngredientsForm = () => {
  const [ingredients, setIngredients] = useState<string>("");

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    // TODO: Handle form to API. Authenticate request with Token
  };

  return (
    <form onSubmit={handleSubmit}>
      <IngredientTextarea
        value={ingredients}
        onChange={(e) => setIngredients(e.target.value)}
      />
      <Button onClick={handleSubmit}>Submit</Button>
    </form>
  );
};
