def query=(query)
  @query = query
end

When /^I query (.*) with scope '(.*)'$/ do |doc, scope|
  klass = doc.singularize.camelize.constantize
  self.query = klass.send(scope)
end

When /^I query (.*) with scopes '(.*)'$/ do |doc, scopes|
  klass = doc.singularize.camelize.constantize
  self.query = scopes.split(',').inject(klass) do |result, scope|
    result.send(scope.strip)
  end
end

When /^I query (.*) with lambda scope '(.*)' with parameters '(.*)'$/ do |doc, scope, params_text|
  klass = doc.singularize.camelize.constantize
  params = params_text.split(',').map(&:strip)
  self.query = klass.send(scope, *params)
end
