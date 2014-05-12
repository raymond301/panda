class Enrichment < ActiveRecord::Base
  require 'rubystats/fishers_exact_test'

  def self.calculate_enrichment_scores(enrichmentObj)
    countsPerPathway = PathwayMap.get_uniq_gene_counts
    global = PathwayMap.global_gene_count
    countsPerAnnotPerPathway = PathwayMap.genes_per_annotation_per_pathway(enrichmentObj.annotation_collection_id).index_by(&:xref)
    totalAnnotationGeneCount = PathwayMap.uniq_gene_count_of_this_annotation(enrichmentObj.annotation_collection_id)
    fisher = Rubystats::FishersExactTest.new

    countsPerPathway.each do |cpp|
     if countsPerAnnotPerPathway[cpp.xref].nil?
       PathwayCount.create(xref: cpp.xref, countable_type: 'Enrichment', countable_id: enrichmentObj.id, count: 1 )
       next
     end

      ### Number of Genes in Both this annotation & pathway
      a = countsPerAnnotPerPathway[cpp.xref].count
      ### Number of Genes in this annotation, NOT found in this pathway.
      b = totalAnnotationGeneCount - a
      ### Number of Genes in this pathway
      c = cpp.count
      ### Number of Genes in entire app
      d = global

      pval = fisher.calculate(a,b,c,d)[:right]

      PathwayCount.create(
          xref: cpp.xref,
          countable_type: 'Enrichment',
          countable_id: enrichmentObj.id, count: pval
      )
    end


  end


end
