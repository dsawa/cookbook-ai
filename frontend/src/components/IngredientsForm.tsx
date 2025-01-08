import { FormEvent, useState } from "react";
import { IngredientTextarea } from "./IngredientTextarea";
import { Button } from "./Button";
import { Spinner } from "./Spinner";
import { Recipe } from "../types/recipe";

interface IngredientsFormProps {
  onSuccess: (recipe: Recipe) => void;
}

export const IngredientsForm = ({ onSuccess }: IngredientsFormProps) => {
  const [ingredients, setIngredients] = useState<string>("");
  const [waitingState, setWaitingState] = useState<boolean>(false);
  const [recipeLoaded, setRecipeLoaded] = useState<boolean>(false);

  const handleErrorSubmit: (error: Error) => void = () => {
    setWaitingState(false);
  };

  const handleSuccessSubmit: (recipe: Recipe) => void = (recipe) => {
    setWaitingState(false);
    setRecipeLoaded(true);
    onSuccess(recipe);
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();

    if (ingredients === "") {
      return;
    }

    setWaitingState(true);

    const token: string = import.meta.env.VITE_API_TOKEN;
    const url: string = import.meta.env.VITE_API_URL;

    const ingredientsArray = ingredients
      .split(",")
      .map((ingredient) => ingredient.trim())
      .filter((ingredient) => ingredient !== "");

    fetch(url + "/recipes", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ ingredients: ingredientsArray }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Request failed with: ${response.status}`);
        }
        return response.json();
      })
      .then(handleSuccessSubmit)
      .catch(handleErrorSubmit);
  };

  const buttonContent = () => {
    if (waitingState) {
      return <Spinner />;
    }

    if (recipeLoaded) {
      return "Try another";
    }

    return "Submit";
  };

  return (
    <form onSubmit={handleSubmit}>
      <IngredientTextarea
        disabled={waitingState}
        value={ingredients}
        onChange={(e) => setIngredients(e.target.value)}
      />
      <Button disabled={waitingState} onClick={handleSubmit}>
        {buttonContent()}
      </Button>
    </form>
  );
};
