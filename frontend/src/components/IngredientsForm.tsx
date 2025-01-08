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

  const handleErrorSubmit: (error: Error) => void = (error) => {
    console.error(error);
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

    // TODO: Authenticate request with JWT ?
    setWaitingState(true);

    const token: string = import.meta.env.VITE_API_TOKEN;
    const url: string = import.meta.env.VITE_API_URL;

    fetch(url + "/recipes", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ ingredients }),
    })
      .then((response) => response.json())
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
