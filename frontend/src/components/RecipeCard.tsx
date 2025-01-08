import { Recipe } from "../types/recipe";

interface RecipeCardProps {
  recipe: Recipe | null;
}

export const RecipeCard = ({ recipe }: RecipeCardProps) => {
  if (!recipe) {
    return null;
  }

  console.log("Recipe Title: " + recipe.title);
  return (
    <div className="card border-success">
      <div className="card-header">{recipe.title}</div>
      <div className="card-body">
        <div className="row">
          <div className="col-12">
            <p className="card-text">{recipe.description}</p>
          </div>
        </div>
        <div className="row my-4">
          <div className="col-6">
            <strong>Time:</strong> {recipe.time}
            <br />
            <strong>Serves:</strong> {recipe.serves}
            <br />
            <strong>Difficulty:</strong> {recipe.difficulty}
          </div>
          <div className="col-6">
            <h5>Ingredients:</h5>
            <ul className="mb-3">
              {recipe.ingredients.map((ingredient, index) => (
                <li key={index} className="list-group-item">
                  {ingredient}
                </li>
              ))}
            </ul>
          </div>
        </div>

        <h5>Steps:</h5>
        <ol className="list-group list-group-numbered">
          {recipe.steps.map((step, index) => (
            <li key={index} className="list-group-item">
              {step}
            </li>
          ))}
        </ol>
      </div>
    </div>
  );
};
