ARTEFACTS_PATH = File.expand_path(__dir__ + '/../../tmp/spec-artefacts')

def write_graphql_result_to_artefact(result, example = RSpec.current_example)
  output_data = { spec: example.metadata, result: result }

  description = example.metadata[:turnip] ? '' : example.description
  contexts = []
  example_group = example.metadata[:example_group]
  # get recursive parent descriptions, except the "root"
  while example_group.try(:fetch, :parent_example_group, false)
    contexts.push(example_group[:description])
    example_group = example.metadata[:parent_example_group]
  end
  filename =
    "#{example.metadata[:scoped_id]}_#{contexts.join('_')}_#{description}".gsub(/\W/, '_').gsub(/_+/, '_')

  dirpath = File.expand_path("#{ARTEFACTS_PATH}/#{example.file_path}")
  fullpath = "#{dirpath}/#{filename}.json"
  FileUtils.mkdir_p(dirpath)
  File.write(fullpath, JSON.pretty_generate(output_data))
end
