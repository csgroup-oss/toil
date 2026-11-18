cwlVersion: v1.2
$graph:
- class: Workflow
  id: main
  inputs: []
  outputs:
    parents:
      type: Directory[]
      outputSource: modify/parents
    products:
      type: Directory[]
      outputSource: modify/products
    files:
      type: File[]
      outputSource: modify/files
    original:
      type: Directory
      outputSource: generate/directory
  steps:
    generate:
      run: "#generate"
      in: {}
      out: [directory]
    modify:
      run: "#modify"
      in:
        directory: generate/directory
      out: [parents, products, files]

- class: CommandLineTool
  id: generate
  inputs: []
  requirements:
    InitialWorkDirRequirement:
      listing:
      - entryname: generate.sh
        entry: |
          set -eu
          for product in product_1 product_2 product_3; do
              mkdir -p "data/$product/nested"
              printf 'original\n' > "data/$product/existing.txt"
              printf 'original\n' > "data/$product/nested/existing.txt"
              printf 'obsolete\n' > "data/$product/obsolete.txt"
          done
  baseCommand: [bash, generate.sh]
  outputs:
    directory:
      type: Directory
      outputBinding:
        glob: data

- class: CommandLineTool
  id: modify
  inputs:
    directory: Directory
  requirements:
    InitialWorkDirRequirement:
      listing:
      - entry: $(inputs.directory)
        entryname: output_0
        writable: true
      - entryname: modify.sh
        entry: |
          set -eu
          for product in output_0/product_*; do
              printf 'updated\n' > "$product/existing.txt"
              printf 'updated\n' > "$product/nested/existing.txt"
              printf 'created\n' > "$product/nested/new.txt"
              touch "$product/test.txt"
              rm "$product/obsolete.txt"
          done
  baseCommand: [bash, modify.sh]
  outputs:
    parents:
      type: Directory[]
      outputBinding:
        glob: output_*
    products:
      type: Directory[]
      outputBinding:
        glob: output_*/product_*
    files:
      type: File[]
      outputBinding:
        glob:
        - output_*/product_*/existing.txt
        - output_*/product_*/nested/existing.txt
