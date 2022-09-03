import getBestLangValue from '../get_best_lang_value.js'
import { getEntitiesByUris } from '../entities.js'
import preq from '#lib/preq'
import { isImageHash } from '#lib/boolean_tests'

export async function addWorksImagesAndAuthors (works) {
  await Promise.all([
    addWorksImages(works),
    addWorksAuthors(works),
  ])
  return works
}

export async function addWorksImages (works) {
  const remainingWorks = works.slice(0)
  const nextBatch = async () => {
    const batchWorks = remainingWorks.splice(0, 10)
    if (batchWorks.length === 0) return
    await Promise.all(batchWorks.map(addWorkImages))
    return nextBatch()
  }
  await nextBatch()
  return works
}

export async function addWorkImages (work) {
  const { uri } = work
  const { images } = await preq.get(app.API.entities.images(work.uri))
  const workImages = images[uri]
  let imageValue = getBestLangValue(app.user.lang, work.originalLang, workImages).value
  if (imageValue) {
    work.image.url = getEntityImagePath(imageValue)
  }
  work.images = Object.values(workImages).flat().map(getEntityImagePath)
  return work
}

const getEntityImagePath = imageValue => {
  if (isImageHash(imageValue)) return `/img/entities/${imageValue}`
  else return imageValue
}

export async function addWorksAuthors (works) {
  const authorsUris = _.uniq(_.compact(_.flatten(works.map(getWorkAuthorsUris))))
  const entities = await getEntitiesByUris({ uris: authorsUris, index: true })
  works.forEach(work => {
    const workAuthorUris = getWorkAuthorsUris(work)
    work.authors = _.values(_.pick(entities, workAuthorUris))
  })
}

const getWorkAuthorsUris = work => work.claims['wdt:P50']
