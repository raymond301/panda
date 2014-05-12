class Gene < ActiveRecord::Base

  def self.find_by_symbol_or_synonym(qry)
    gene = Gene.find_by_symbol(qry)
    if !gene.nil?
      return gene
    else
      return Gene.find_by_sql("SELECT * FROM genes JOIN gene_synonyms AS gs ON genes.id = gs.gene_id WHERE gs.name = '#{qry}';").first rescue nil
    end #logic
  end

end
