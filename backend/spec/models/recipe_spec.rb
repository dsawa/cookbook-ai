require_relative '../spec_helper'
require_relative '../../models/recipe'

describe Recipe do
  let(:attributes) do
    {
      title: "Simple Sweet Pancakes",
      description: "Light and fluffy pancakes made with basic ingredients",
      ingredients: [
        "2 cups of flour",
        "3 tablespoons of sugar",
        "100g melted butter",
        "2 cups of milk"
      ],
      steps: [
        "Mix flour and sugar in a large bowl",
        "Warm up the milk slightly and melt the butter",
        "Gradually add milk to the dry ingredients while whisking",
        "Add melted butter and mix until smooth",
        "Heat a non-stick pan over medium heat",
        "Pour about 1/4 cup of batter for each pancake",
        "Cook until bubbles form on surface, then flip",
        "Cook other side until golden brown"
      ],
      time: "30 minutes",
      serves: "4 people",
      difficulty: "easy"
    }
  end

  subject { Recipe.new(attributes) }

  describe '#valid?' do
    context 'valid attributes' do
      it { is_expected.to be_valid }
    end

    context 'invalid attributes' do
      subject { Recipe.new(invalid_attributes) }

      context 'validates presence and array for steps and ingredients' do
        let(:invalid_attributes) { attributes.keys.each_with_object({}) { |key, hash| hash[key] = nil } }

        it { is_expected.not_to be_valid }

        it 'has errors' do
          subject.valid?
          expect(subject.errors.full_messages).to include(
            "Title can't be blank",
            "Description can't be blank",
            "Ingredients must be an array",
            "Steps must be an array",
            "Time can't be blank",
            "Serves can't be blank",
            "Difficulty can't be blank"
          )
        end
      end
    end
  end
end
