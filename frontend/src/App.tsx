import "./App.css";
import { CookbookHeader } from "./components/CookbookHeader";
import { IntroductionParagraph } from "./components/IntroductionParagraph";
import { Separator } from "./components/Separator";
import { IngredientsForm } from "./components/IngredientsForm";
import { RecipeCard } from "./components/RecipeCard";
import { useState } from "react";
import { Recipe } from "./types/recipe";

function App() {
  const [recipe, setRecipe] = useState<Recipe | null>(null);

  const recipeCallback = (recipe: Recipe) => {
    console.log("recipeCallback");
    console.log(recipe);
    setRecipe(recipe);
  };

  return (
    <>
      <div className="container">
        <div className="row text-center">
          <div className="col-12">
            <CookbookHeader />
          </div>
          <div className="col-12">
            <div className="text-center">
              <IntroductionParagraph />
              <Separator />
              <IngredientsForm onSuccess={recipeCallback} />
              <Separator />
              <RecipeCard recipe={recipe} />
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default App;
