import { I18n } from '#user/lib/i18n'
import { isNonEmptyArray } from '#lib/boolean_tests'

export const getCounterText = editionItems => I18n('users_count_have_this_book', { smart_count: getUsersSizePerEdition(editionItems) })

export const getUsersSizePerEdition = editionItems => {
  if (isNonEmptyArray(editionItems)) {
    const notMainUserOwners = editionItems.filter(notMainUserOwner)
    return _.uniq(notMainUserOwners).length
  }
}

const notMainUserOwner = doc => doc.owner !== app.user.id
