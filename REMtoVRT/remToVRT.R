library(dplyr)

# list of files
files <- paste("rem-coraxml-20161222/", list.files("rem-coraxml-20161222/"), sep="")
files <- files[-grep("README", files)]

# list of tags
tags <- c("infl", "inflClass", "inflClass_gen", "lemma", "lemma_gen", "lemma_idmwb", "norm", "pos", "pos_gen", "punc", "token_type")

# list of metakeys
metakeys <- c("<abbr_ddd>","<abbr_mwb>","<annotation_by>","<collation_by>",
              "<corpus>","<date>","<digitization_by>","<edition>","<extent>",
              "<extract>","<genre>","<language>","<language-area>",
              "<language-region>","<language-type>","<library>",
              "<library-shelfmark>","<medium>","<notes-annotation>",
              "<notes-manuscript>","<notes-transcription>","<online>",
              "<place>","<pre_editing_by>","<proofreading_by>","<reference>",
              "<reference-secondary>","<text>","<text-author>","<text-language>",
              "<text-place>","<text-source>","<text-type>","<time>","<topic>","<annis:doc>")


# create dataframe
df <- as.data.frame(matrix(ncol=length(tags)+2, nrow=0))
colnames(df) <- c("tok_dipl", "tok_anno", tags)


for(doc in 1:length(files)) {
  # read current document
  current <- scan(files[doc], what="char", sep="\n",
                  fileEncoding = "UTF-8", quote="")
  
  # replace all ampersands (as they cause problems in CQP)
  current <- gsub("&", "AMPERSAND", current)

  
  # find tokens
  t <- grep("<token id=", current)
  t_end <- grep("</token", current)
  
  # create dataframe
  df <- as.data.frame(matrix(ncol=length(tags)+2, nrow=0))
  colnames(df) <- c("tok_dipl", "tok_anno", tags) 
  
  # populate dataframe
  for(j in 1:length(t)) {
    # find annotations
    c <- current[t[j]:t_end[j]] # current slice
    df[j,] <- NA
    
    if(length(grep("<tok_dipl", c))>0) {
      if(length(grep("<tok_dipl", c))>1) {
        cc <- c[grep("<tok_dipl", c)]
        df$tok_dipl[j] <- paste(sapply(1:length(cc), function(txt) gsub("\".*", "", unlist(strsplit(grep("<tok_dipl", cc[txt], value=T), "utf=\""))[2])), collapse="")
      } else {
        df$tok_dipl[j] <- gsub("\".*", "", unlist(strsplit(grep("<tok_dipl", c, value=T), "utf=\""))[2])
      }
      
    }
    
    if(length(grep("<tok_anno", c))>0) {
      if(length(grep("<tok_anno", c))>1) {
        cc <- c[grep("<tok_anno", c)]
        df$tok_anno[j] <- paste(sapply(1:length(cc), function(txt) gsub("\".*", "", unlist(strsplit(grep("<tok_anno", cc[txt], value=T), "utf=\""))[2])), collapse="")
      } else {
        df$tok_anno[j] <- gsub("\".*", "", unlist(strsplit(grep("<tok_anno", c, value=T), "utf=\""))[2])
      }
      
    }
    
    
    for(i in 1:length(tags)) {
      if(length(grep(paste(tags[i], " tag", sep=""), c, value=T))>0) {
        
        c_tag <- gsub(".* tag=\"|\"/>", "", grep(paste(tags[i], " tag", sep=""), c, value=T))
        
        if(length(c_tag)>1) {
          c_tag <- paste(c_tag, collapse="_&_&")
        }
        
        df[j,(i+2)] <- c_tag
        
      }
      
      #print(i)
      
    }
    
    
    
  }
  
  # get metatags and write document
  metatags <- c()
  
  for(i in 1:length(metakeys)) {
    if(length(grep(metakeys[i], current))>0) {
      c_mkey <- grep(metakeys[i], current, value=T)
      metatags[i] <- paste(gsub("<|>", "", metakeys[i]), "=\"",  gsub("</.*", "", gsub("^ *", "", gsub(metakeys[i], "", c_mkey))), "\"", sep="", collapse="")
    } else {
      metatags[i] <- paste(gsub("<|>", "", metakeys[i]), "=\"-\"", sep="", collapse="")
    }
  }
  
  
  write.table("<?xml version='1.0' encoding='UTF-8'?>", 
              file = paste("rem-vrt/", gsub(".xml", "", gsub("rem-coraxml-20161222/", "", files[doc])),
                           ".vrt", sep="", collapse=""),
              row.names=F, col.names = F, quote=F,
              fileEncoding = "UTF-8")
  
  write.table(paste("<text ", paste(metatags, sep="", collapse=" "), ">", sep="", collapse=" "),
              file = paste("rem-vrt/", gsub(".xml", "", gsub("rem-coraxml-20161222/", "", files[doc])),
                           ".vrt", sep="", collapse=""),
              row.names=F, col.names = F, quote=F,
              fileEncoding = "UTF-8", append = T)
  
  write.table("<p>",
              file = paste("rem-vrt/", gsub(".xml", "", gsub("rem-coraxml-20161222/", "", files[doc])),
                           ".vrt", sep="", collapse=""),
              row.names=F, col.names = F, quote=F, sep="\t",
              fileEncoding = "UTF-8", append = T)
  
  write.table(df,
              file = paste("rem-vrt/", gsub(".xml", "", gsub("rem-coraxml-20161222/", "", files[doc])),
                           ".vrt", sep="", collapse=""),
              row.names=F, col.names = F, quote=F, sep="\t",
              fileEncoding = "UTF-8", append = T)
  
  
  write.table("</p>\n</text>",
              file = paste("rem-vrt/", gsub(".xml", "", gsub("rem-coraxml-20161222/", "", files[doc])),
                           ".vrt", sep="", collapse=""),
              row.names=F, col.names = F, quote=F, sep="\t",
              fileEncoding = "UTF-8", append = T)
  
  
  
  
  print(doc)
  
}

# remove ":" from structural attribute names
for(i in 2:length(files)) {
  current <- scan(gsub("xml", "vrt", gsub("rem-coraxml-20161222", "rem-vrt", files[i])), 
                  what="char", sep="\n",
                  fileEncoding = "UTF-8", quote="")
  
  current[2] <- gsub("annis:doc", "annis_doc", current[2])
  write.table(current, file=gsub("xml", "vrt", gsub("rem-coraxml-20161222", "rem-vrt", files[i])),
              row.names=F, col.names=F, quote=F, fileEncoding = "UTF-8")
  
}

# correct metakeys
for(j in 1:length(files)) {
  current <- scan(files[j], 
                  what="char", sep="\n",
                  fileEncoding = "UTF-8", quote="", nmax = 100)
  
  for(i in 1:length(metakeys)) {
    if(length(grep(metakeys[i], current))>0) {
      c_mkey <- grep(metakeys[i], current, value=T)
      c_mkey <- gsub("\"", "", c_mkey)
      metatags[i] <- paste(gsub("<|>", "", metakeys[i]), "=\"",  gsub("</.*", "", gsub("^ *", "", gsub(metakeys[i], "", c_mkey))), "\"", sep="", collapse="")
    } else {
      metatags[i] <- paste(gsub("<|>", "", metakeys[i]), "=\"-\"", sep="", collapse="")
    }
  }
  
  rm(current)
  
  current <- scan(gsub("xml", "vrt", gsub("rem-coraxml-20161222", "rem-vrt", files[j])), 
                  what="char", sep="\n",
                  fileEncoding = "UTF-8", quote="")
  
  current[2] <- paste("<text ", paste(metatags, sep="", collapse=" "), ">", sep="", collapse=" ")
  write.table(current, file=gsub("xml", "vrt", gsub("rem-coraxml-20161222", "rem-vrt", files[j])),
              row.names=F, col.names=F, quote=F, fileEncoding = "UTF-8")
  
  rm(current)
  
}

# remove ":" from structural attribute names (again)
for(i in 1:length(files)) {
  current <- scan(gsub("xml", "vrt", gsub("rem-coraxml-20161222", "rem-vrt", files[i])), 
                  what="char", sep="\n",
                  fileEncoding = "UTF-8", quote="")
  
  current[2] <- gsub("annis:doc", "annis_doc", current[2])
  write.table(current, file=gsub("xml", "vrt", gsub("rem-coraxml-20161222", "rem-vrt", files[i])),
              row.names=F, col.names=F, quote=F, fileEncoding = "UTF-8")
  
}

