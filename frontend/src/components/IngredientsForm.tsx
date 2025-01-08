import { FormEvent, useState } from "react";
import { IngredientTextarea } from "./IngredientTextarea";
import { Button } from "./Button";
import { Spinner } from "./Spinner";
import { Recipe } from "../types/recipe";
import { Alert } from "./Alert";

interface IngredientsFormProps {
  onSuccess: (recipe: Recipe) => void;
}

interface ApiErrorResponse {
  title: string;
  status: number;
  detail: string;
  errors: Record<string, unknown>;
}

export const IngredientsForm = ({ onSuccess }: IngredientsFormProps) => {
  const [ingredients, setIngredients] = useState<string>("");
  const [waitingState, setWaitingState] = useState<boolean>(false);
  const [recipeLoaded, setRecipeLoaded] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleErrorSubmit: (error: Error) => void = (error: Error) => {
    setWaitingState(false);
    setError(error.message);
    console.error(error);
  };

  const handleSuccessSubmit: (recipe: Recipe) => void = (recipe) => {
    setWaitingState(false);
    setRecipeLoaded(true);
    onSuccess(recipe);
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();

    if (ingredients === "") {
      setError("Please enter some ingredients");
      return;
    }

    setError(null);
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
      .then(async (response) => {
        if (!response.ok) {
          const errorData = (await response.json()) as ApiErrorResponse;
          throw new Error(errorData.title || "Something went wrong");
        }

        return response.json() as Promise<Recipe>;
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
    <div>
      {error && <Alert>{error}</Alert>}
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
    </div>
  );
};
