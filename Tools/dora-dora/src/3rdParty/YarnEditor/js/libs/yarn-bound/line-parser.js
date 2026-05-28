// mutates node, processing [markup /] and `character:`
export default function parseLine (node, locale) {
  node.markup = []
  parseCharacterLabel(node)
  parseMarkup(node, locale)
  node.text = node.text.replace(/(?:\\(.))/g, '$1')
}

function parseCharacterLabel (node) {
  const match = node.text.match(/^(\S+):\s+/)
  if (match) {
    node.text = node.text.replace(match[0], '')
    node.markup.push({ name: 'character', properties: { name: match[1] } })
  }
}

function parseMarkup (node, locale) {
  const attributes = []
  let noMarkup = false

  const attributeRegex = /(^|[^\\])\[(.*?[^\\])\](.|$)/
  let textRemaining = node.text
  let resultText = ''
  let match = textRemaining.match(attributeRegex)
  while (match) {
    const { index } = match
    const [wholeMatch, charBefore, contents, charAfter] = match
    const hasLeadingSpace = /\s/.test(charBefore)
    const hasTrailingSpace = /\s/.test(charAfter)

    const attribute = {
      ...parseAttributeContents(contents, locale),
      position: resultText.length + index + charBefore.length
    }

    if (!noMarkup || attribute.name === 'nomarkup') {
      const isReplacementTag = attribute.name === 'select' ||
        attribute.name === 'plural' ||
        attribute.name === 'ordinal'
      const shouldTrim = !isReplacementTag &&
        attribute.isSelfClosing &&
        attribute.properties &&
        attribute.properties.trimwhitespace !== false &&
        ((index === 0 && hasTrailingSpace) || (hasLeadingSpace && hasTrailingSpace))
      if (attribute.properties) {
        delete attribute.properties.trimwhitespace
      }
      const replacement = charBefore +
        (attribute.replacement || '') +
        (shouldTrim
          ? charAfter.slice(1)
          : charAfter)

      textRemaining = textRemaining.replace(attributeRegex, replacement)
      // inner slices are because charAfter could be an opening square bracket
      resultText += textRemaining.slice(0, index + replacement.slice(1).length)
      textRemaining = textRemaining.slice(index + replacement.slice(1).length)
      if (!isReplacementTag && attribute.name !== 'nomarkup') {
        attributes.push(attribute)
      }
    } else {
      // -1s are because charAfter could be an opening square bracket
      resultText += textRemaining.slice(0, index + wholeMatch.length - 1)
      textRemaining = textRemaining.slice(index + wholeMatch.length - 1)
    }

    if (attribute.name === 'nomarkup') {
      noMarkup = !attribute.isClosing
    }

    match = textRemaining.match(attributeRegex)
  }

  node.text = resultText + textRemaining

  // Escaped bracket support might need some TLC.
  const escapedCharacterRegex = /\\(\[|\])/
  match = node.text.match(escapedCharacterRegex)
  textRemaining = node.text
  resultText = ''
  while (match) {
    const char = match[1]
    attributes.forEach((attr) => {
      if (attr.position > resultText.length + match.index) {
        attr.position -= 1
      }
    })
    textRemaining = textRemaining.replace(escapedCharacterRegex, char)
    resultText += textRemaining.slice(0, match.index + 1)
    textRemaining = textRemaining.slice(match.index + 1)

    match = textRemaining.match(escapedCharacterRegex)
  }

  node.text = resultText + textRemaining

  const openTagStacks = {}
  attributes.forEach((attr) => {
    if (!openTagStacks[attr.name]) {
      openTagStacks[attr.name] = []
    }

    if (attr.isClosing && !openTagStacks[attr.name].length) {
      throw new Error(`Encountered closing ${attr.name} tag before opening tag`)
    } else if (attr.isClosing) {
      const openTag = openTagStacks[attr.name].pop()
      node.markup.push({
        name: openTag.name,
        position: openTag.position,
        properties: openTag.properties,
        length: attr.position - openTag.position
      })
    } else if (attr.isSelfClosing) {
      node.markup.push({
        name: attr.name,
        position: attr.position,
        properties: attr.properties,
        length: 0
      })
    } else if (attr.isCloseAll) {
      const openTags = Object.values(openTagStacks).flat()
      while (openTags.length) {
        const openTag = openTags.pop()
        node.markup.push({
          name: openTag.name,
          position: openTag.position,
          properties: openTag.properties,
          length: attr.position - openTag.position
        })
      }
    } else {
      openTagStacks[attr.name].push({
        name: attr.name,
        position: attr.position,
        properties: attr.properties
      })
    }
  })
}

function parseAttributeContents (contents, locale) {
  const nameMatch = contents.match(/^\/?([^\s=/]+)(\/|\s|$)/)
  const isClosing = contents[0] === '/'
  const isSelfClosing = contents[contents.length - 1] === '/'
  const isCloseAll = contents === '/'
  if (isCloseAll) {
    return { name: 'closeall', isCloseAll: true }
  } else if (isClosing) {
    return { name: nameMatch[1], isClosing: true }
  } else {
    const propertyAssignmentsText = nameMatch
      ? contents.replace(nameMatch[0], '')
      : contents
    const propertyAssignments = propertyAssignmentsText
      .match(/(\S+?".*?"|[^\s/]+)/g)
    let properties = {}
    if (propertyAssignments) {
      properties = propertyAssignments.reduce((acc, propAss) => {
        return { ...acc, ...parsePropertyAssignment(propAss) }
      }, {})
    }

    const name = (nameMatch && nameMatch[1]) || Object.keys(properties)[0]

    let replacement
    if (name === 'select') {
      replacement = processSelectAttribute(properties)
    } else if (name === 'plural') {
      replacement = processPluralAttribute(properties, locale)
    } else if (name === 'ordinal') {
      replacement = processOrdinalAttribute(properties, locale)
    }

    return {
      name,
      properties,
      isSelfClosing,
      replacement
    }
  }
}

function parsePropertyAssignment (propAss) {
  const [propName, ...rest] = propAss.split('=')
  const stringValue = rest.join('=') // just in case string value had a = in it
  if (!propName || !stringValue) {
    throw new Error(`Invalid markup property assignment: ${propAss}`)
  }
  let value
  if (stringValue === 'true' || stringValue === 'false') {
    value = stringValue === 'true'
  } else if (/^-?\d*\.?\d+$/.test(stringValue)) {
    value = +stringValue
  } else if (stringValue[0] === '"' && stringValue[stringValue.length - 1] === '"') {
    value = stringValue.slice(1, -1)
  } else {
    value = stringValue
  }
  return { [propName]: value }
}

function processSelectAttribute (properties) {
  return properties[properties.value]
}

function processPluralAttribute (properties, locale) {
  return properties[(new Intl.PluralRules(locale)).select(properties.value)]
    .replace(/%/g, properties.value)
}

function processOrdinalAttribute (properties, locale) {
  return properties[(new Intl.PluralRules(locale, { type: 'ordinal' })).select(properties.value)]
    .replace(/%/g, properties.value)
}
