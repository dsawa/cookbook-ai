import './App.css'
import { CookbookHeader } from './components/CookbookHeader'
import { IntroductionParagraph } from './components/IntroductionParagraph'
import { Separator } from './components/Separator'
import { IngredientsForm } from './components/IngredientsForm'

function App() {
  return (
    <>
      <div className='container'>
        <div className='row'>
          <div className='col-12'>
            <CookbookHeader />
            <IntroductionParagraph />
            <Separator />
            <IngredientsForm />
          </div>
        </div>
      </div>
    </>
  )
}

export default App
