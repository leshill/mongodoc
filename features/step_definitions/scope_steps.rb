def scope_query=(scope)
  @query = scope
end

When /^I query (.*) with scope '(.*)'$/ do |doc, scope|
  self.scope_query = klass(doc).send(scope)
end

When /^I query (.*) with scopes '(.*)'$/ do |doc, scopes|
  self.scope_query = scopes.split(',').inject(klass(doc)) do |result, scope|
    result.send(scope.strip)
  end
end

When /^I query (.*) with lambda scope '(.*)' with parameters '(.*)'$/ do |doc, scope, params_text|
  params = params_text.split(',').map(&:strip)
  self.scope_query = klass(doc).send(scope, *params)
end
