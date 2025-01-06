import { FormEvent, useState } from "react";
import { IngredientTextarea } from "./IngredientTextarea";
import { Button } from "./Button";
import { Spinner } from "./Spinner";

export const IngredientsForm = () => {
  const [ingredients, setIngredients] = useState<string>("");
  const [waitingState, setWaitingState] = useState<boolean>(false);

  const handleErrorSubmit: (error: Error) => void = (error) => {
    console.error(error);
    setWaitingState(false);
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    // TODO: Authenticate request with JWT ?
    setWaitingState(true);

    const token: string = import.meta.env.VITE_API_TOKEN;
    const url: string = import.meta.env.VITE_API_URL;

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ ingredients }),
    }).catch(handleErrorSubmit);
  };

  const buttonContent = () => {
    if (waitingState) {
      return <Spinner />;
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
