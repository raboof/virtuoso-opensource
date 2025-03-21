--
--  $Id$
--
--  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
--  project.
--
--  Copyright (C) 1998-2021 OpenLink Software
--
--  This project is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; only version 2 of the License, dated June 1991.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
--
--

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_XML_WRITE_NS (inout ses any)
{
  --http ('<?xml version="1.0" encoding="UTF-8"?>\n', ses);
  http ('<sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">', ses);
}
;


--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_XML_WRITE_HEAD (inout ses any, in colnames any)
{
  declare i, col_count integer;
  http ('\n <head>', ses);
  i := 0; col_count := length (colnames);
  while (i < col_count)
    {
      http (sprintf ('\n  <variable name="%s"/>', colnames[i]), ses);
      i := i + 1;
    }
  http ('\n </head>', ses);
}
;

--!AWK PUBLIC
create function DB.DBA.SPARQL_RSET_XML_HTTP_PRE (in colnames any, in accept varchar)
{
  declare ses integer;
  ses := 0;
  -- dbg_obj_princ ('DB.DBA.SPARQL_RSET_XML_HTTP_PRE (', colnames, accept, ')');
  if (strchr (accept, ' ') is not null)
    accept := subseq (accept, strchr (accept, ' ')+1);
  http_header ('Content-Type: ' || accept || '; charset=UTF-8\r\n');
  http_flush (1);
  DB.DBA.SPARQL_RSET_XML_WRITE_NS (ses);
  DB.DBA.SPARQL_RSET_XML_WRITE_HEAD (ses, colnames);
  http ('\n <results>');
  return colnames;
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_XML_HTTP_INIT (inout env any)
{
  env := 0;
}
;

--!AWK PUBLIC
create function DB.DBA.SPARQL_RSET_XML_HTTP_FINAL (inout env any)
{
  http ('\n </results>');
  http ('\n</sparql>');
}
;

--!AWK PUBLIC
create aggregate DB.DBA.SPARQL_RSET_XML_HTTP (inout colnames any, inout row any) from
  DB.DBA.SPARQL_RSET_XML_HTTP_INIT,
  sparql_rset_xml_write_row,
  DB.DBA.SPARQL_RSET_XML_HTTP_FINAL
order
;


--!AWK PUBLIC
create function DB.DBA.SPARQL_DICT_XML_HTTP_PRE (in colnames any, in accept varchar)
{
  declare ses integer;
  -- dbg_obj_princ ('DB.DBA.SPARQL_DICT_XML_HTTP_PRE (', colnames, accept, ')');
  http_header ('Content-Type: ' || accept || '; charset=UTF-8\r\n');
  http_flush (1);
  ses := 0;
  DB.DBA.SPARQL_RSET_XML_WRITE_NS (ses);
  http ('\n <head><variable name="S"/><variable name="P"/><variable name="O"/></head>');
  http ('\n <results distinct="false" ordered="true">');
  return colnames;
}
;

--!AWK PUBLIC
create aggregate DB.DBA.SPARQL_DICT_XML_HTTP (inout colnames any, inout row any) from
  DB.DBA.SPARQL_RSET_XML_HTTP_INIT,
  sparql_dict_xml_write_row,
  DB.DBA.SPARQL_RSET_XML_HTTP_FINAL
;


--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_TTL_WRITE_NS (inout ses any)
{
  http ('@prefix res: <http://www.w3.org/2005/sparql-results#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
_:_ a res:ResultSet .\n', ses);
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_TTL_WRITE_HEAD (inout ses any, in colnames any)
{
  declare i, col_count integer;
  col_count := length (colnames);
  if (0 = col_count)
    return;
  http ('_:_ res:resultVariable "', ses);
  for (i := 0; i < col_count; i := i + 1)
    {
      if (i > 0)
        http ('" , "', ses);
      http_escape (colnames[i], 11, ses, 0, 1);
    }
  http ('" .\n', ses);
}
;

--!AWK PUBLIC
create function DB.DBA.SPARQL_RSET_TTL_HTTP_PRE (in colnames any, in accept varchar)
{
  declare ses, colctr, colcount integer;
  declare res any;
  -- dbg_obj_princ ('DB.DBA.SPARQL_RSET_TTL_HTTP_PRE (', colnames, accept, ')');
  http_header ('Content-Type: ' || accept || '; charset=UTF-8\r\n');
  http_flush (1);
  ses := 0;
  DB.DBA.SPARQL_RSET_TTL_WRITE_NS (ses);
  DB.DBA.SPARQL_RSET_TTL_WRITE_HEAD (ses, colnames);
  colcount := length (colnames);
  res := make_array (colcount * 7, 'any');
  for (colctr := 0; colctr < colcount; colctr := colctr + 1)
    {
      res [colctr * 7] := colnames [colctr];
    }
  return DB.DBA.RDF_TRIPLES_TO_TTL_ENV (16000, 0, res, ses);
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_TTL_HTTP_INIT (inout env any)
{
  env := 0;
}
;

--!AWK PUBLIC
create function DB.DBA.SPARQL_RSET_TTL_HTTP_FINAL (inout env any)
{
  ;
}
;

--!AWK PUBLIC
create aggregate DB.DBA.SPARQL_RSET_TTL_HTTP (inout colnames any, inout row any) from
  DB.DBA.SPARQL_RSET_TTL_HTTP_INIT,
  sparql_rset_ttl_write_row,
  DB.DBA.SPARQL_RSET_TTL_HTTP_FINAL
order
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_NT_WRITE_NS (inout ses any)
{
  http ('_:ResultSet2053 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#ResultSet> .\n', ses);
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_RSET_NT_WRITE_HEAD (inout ses any, in colnames any)
{
  declare i, col_count integer;
  col_count := length (colnames);
  for (i := 0; i < col_count; i := i + 1)
    {
      http ('_:ResultSet2053 <http://www.w3.org/2005/sparql-results#resultVariable> "', ses);
      http_escape (colnames[i], 11, ses, 0, 1);
      http ('" .\n', ses);
    }
}
;

--!AWK PUBLIC
create function DB.DBA.SPARQL_RSET_NT_HTTP_PRE (in colnames any, in accept varchar)
{
  declare ses, colctr, colcount integer;
  declare res any;
  -- dbg_obj_princ ('DB.DBA.SPARQL_RSET_NT_HTTP_PRE (', colnames, accept, ')');
  http_header ('Content-Type: ' || accept || '; charset=UTF-8\r\n');
  http_flush (1);
  ses := 0;
  DB.DBA.SPARQL_RSET_NT_WRITE_NS (ses);
  DB.DBA.SPARQL_RSET_NT_WRITE_HEAD (ses, colnames);
  colcount := length (colnames);
  res := make_array (colcount * 7, 'any');
  for (colctr := 0; colctr < colcount; colctr := colctr + 1)
    {
      res [colctr * 7] := colnames [colctr];
    }
  return vector (0, res, 0);
}
;

--!AWK PUBLIC
create aggregate DB.DBA.SPARQL_RSET_NT_HTTP (inout colnames any, inout row any) from
  DB.DBA.SPARQL_RSET_TTL_HTTP_INIT,
  sparql_rset_nt_write_row,
  DB.DBA.SPARQL_RSET_TTL_HTTP_FINAL
order
;

-----
-- SPARQL protocol client, i.e., procedures to execute remote SPARQL statements.

create procedure DB.DBA.SPARQL_REXEC_INT (
  in res_mode integer,
  in res_make_obj integer,
  in service varchar,
  in query varchar,
  in dflt_graph varchar,
  inout named_graphs any,
  inout req_hdr any,
  in maxrows integer,
  inout metas any,
  inout bnode_dict any,
  in expected_var_list any := null,
  in options any := null
  )
{
  declare quest_pos integer;
  declare req_uri, req_method, req_body, local_req_hdr, ret_body, ret_hdr any;
  declare ret_content_type, ret_known_content_type, ret_format varchar;
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT (', res_mode, res_make_obj, service, query, dflt_graph, named_graphs, req_hdr, maxrows, metas, bnode_dict, options, ')');
  quest_pos := strchr (service, '?');
  req_body := string_output();
  if (quest_pos is not null)
    {
      http (subseq (service, quest_pos+1), req_body);
      http ('&', req_body);
      service := subseq (service, 0, quest_pos);
    }
  http ('query=', req_body);
  http_url (query, 0, req_body);
  if (dflt_graph is not null and dflt_graph <> '')
    {
      http ('&default-graph-uri=', req_body);
      http_url (dflt_graph, 0, req_body);
    }
  foreach (varchar uri in named_graphs) do
    {
      http ('&named-graph-uri=', req_body);
      http_url (uri, 0, req_body);
    }
  if (maxrows is not null)
    http (sprintf ('&maxrows=%d', maxrows), req_body);
  req_body := string_output_string (req_body);
  local_req_hdr := 'Accept: application/sparql-results+xml, text/rdf+n3, text/rdf+ttl, text/rdf+turtle, text/turtle, application/turtle, application/x-turtle, application/rdf+xml, application/xml';
  req_method := coalesce (
    get_keyword ('req_method', options, null),
    (sparql define input:storage "" select ?mtd from virtrdf: where { `iri(?:service)` virtrdf:bestRequestMethod ?mtd }),
    case when (length (req_body) + length (service) >= 1900) then 'POST' else 'GET' end );
  if ('POST' = req_method)
    {
      req_uri := service;
      local_req_hdr := local_req_hdr || '\r\nContent-Type: application/x-www-form-urlencoded';
    }
  else
    {
      req_method := 'GET';
      req_uri := service || '?' || req_body;
      req_body := '';
    }
  if (length (req_hdr) > 0)
    req_hdr := concat (req_hdr, '\r\n', local_req_hdr );
  else
    req_hdr := local_req_hdr;
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT Request: ', req_method, req_uri);
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT Request: ', req_hdr);
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT Request: ', req_body);
  ret_body := http_get (req_uri, ret_hdr, req_method, req_hdr, req_body, null, 15);
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT Returned header: ', ret_hdr);
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT Returned body: ', ret_body);
  ret_content_type := http_request_header (ret_hdr, 'Content-Type', null, null);
  ret_known_content_type := http_sys_find_best_sparql_accept (ret_content_type, 0, ret_format);
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT ret_content_type=', ret_content_type, ' ret_known_content_type=', ret_known_content_type, ' ret_format=', ret_format);
  if (ret_format is null or not (ret_format in ('XML', 'RDFXML', 'TTL')))
    {
      declare ret_begin, ret_html any;
      ret_begin := "LEFT" (ret_body, 1024);
      ret_html := xtree_doc (ret_begin, 2);
      -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_INT ret_html=', ret_html);
      if (xpath_eval ('/html|/xhtml', ret_html) is not null)
        ret_format := 'HTML';
      else if (xpath_eval ('[xmlns:rset="http://www.w3.org/2005/sparql-results#"] /rset:sparql', ret_html) is not null
            or xpath_eval ('[xmlns:rset2="http://www.w3.org/2001/sw/DataAccess/rf1/result2"] /rset2:sparql', ret_html) is not null)
        ret_format := 'XML';
      else if (xpath_eval ('[xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"] /rdf:rdf', ret_html) is not null)
        ret_format := 'RDFXML';
      else if (strstr (ret_begin, '<html>') is not null or
        strstr (ret_begin, '<xhtml>') is not null )
        ret_format := 'HTML';
    }
  if (ret_format = 'XML')
    {
      declare ret_xml, var_list, var_metas, ret_row, out_nulls any;
      declare var_ctr, var_count integer;
      declare vect_acc any;
      declare row_inx integer;
      -- dbg_obj_princ ('application/sparql-results+xml ret_body=', ret_body); string_to_file ('DB.DBA.SPARQL_REXEC_INT.reply.xml', ret_body, -2);
      ret_xml := xtree_doc (ret_body, 0);
      var_list := xpath_eval ('[xmlns:rset="http://www.w3.org/2005/sparql-results#"] [xmlns:rset2="http://www.w3.org/2001/sw/DataAccess/rf1/result2"]
                               /rset:sparql/rset:head/rset:variable/@name | /rset2:sparql/rset2:head/rset2:variable/@name', ret_xml, 0);
      if (0 = length (var_list))
        {
	  declare bool_ret any;
          bool_ret := xpath_eval ('[xmlns:rset="http://www.w3.org/2005/sparql-results#"] [xmlns:rset2="http://www.w3.org/2001/sw/DataAccess/rf1/result2"]
                                   /rset:sparql/rset:boolean | /rset2:sparql/rset2:boolean', ret_xml);
	  if (bool_ret is not null)
	    {
	      bool_ret := cast (bool_ret as varchar);
	      if ('true' = bool_ret)
	        bool_ret := 1;
	      else if ('false' = bool_ret)
	        bool_ret := 0;
	      else
                signal ('RDFZZ', sprintf (
                    'DB.DBA.SPARQL_REXEC(''%.300s'', ...) has received invalid boolean value ''%.300s''',
                    service, bool_ret ) );
              metas :=
	        vector (
		  vector (
	            vector ('__ask_retval', 242, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0) ),
		  1 );
              if (0 = res_mode)
	        {
		  declare __ask_retval integer;
		  result_names (__ask_retval);
		  result (bool_ret);
		}
              else if (1 = res_mode)
	        return vector (vector (bool_ret));
	      return;
	    }
          signal ('RDFZZ', sprintf (
            'DB.DBA.SPARQL_REXEC(''%.300s'', ...) has received result with no variables',
	    service ) );
	}
      var_count := length (var_list);
      if (expected_var_list is not null)
        {
          for (var_ctr := var_count - 1; var_ctr >= 0; var_ctr := var_ctr - 1)
            {
              declare var_name varchar;
              var_name := cast (var_list[var_ctr] as varchar);
              if (0 >= position (var_name, expected_var_list))
                signal ('RDFZZ', sprintf (
                  'DB.DBA.SPARQL_REXEC(''%.300s'', ...) has received result with unexpected variable name ''%.300s''',
                  service, var_name ) );
            }
          var_list := expected_var_list;
          var_count := length (var_list);
        }
      var_metas := make_array (var_count, 'any');
      out_nulls := make_array (var_count, 'any');
      for (var_ctr := var_count - 1; var_ctr >= 0; var_ctr := var_ctr - 1)
        {
          declare var_name varchar;
          var_name := cast (var_list[var_ctr] as varchar);
          var_list [var_ctr] := var_name;
          var_metas [var_ctr] := vector (var_name, 242, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0);
          out_nulls [var_ctr] := null;
        }
      -- dbg_obj_princ ('var_metas=', var_metas);
      if (0 = res_mode)
        exec_result_names (var_metas);
      else if (1 = res_mode)
        vectorbld_init (vect_acc);
      row_inx := 0;
      for (ret_row := xpath_eval ('[xmlns:rset="http://www.w3.org/2005/sparql-results#"] [xmlns:rset2="http://www.w3.org/2001/sw/DataAccess/rf1/result2"]
                                   /rset:sparql/rset:results/rset:result | /rset2:sparql/rset2:results/rset2:result', ret_xml);
        ret_row is not null;
        ret_row := xpath_eval ('[xmlns:rset="http://www.w3.org/2005/sparql-results#"] [xmlns:rset2="http://www.w3.org/2001/sw/DataAccess/rf1/result2"]
                                following-sibling::rset:result | following-sibling::rset2:result', ret_row) )
        {
          declare out_fields, ret_cols any;
          declare col_ctr, col_count integer;
          out_fields := out_nulls;
          ret_cols := xpath_eval ('[xmlns:rset="http://www.w3.org/2005/sparql-results#"] [xmlns:rset2="http://www.w3.org/2001/sw/DataAccess/rf1/result2"]
                                   rset:binding | rset2:binding', ret_row, 0);
          col_count := length (ret_cols);
          for (col_ctr := col_count - 1; col_ctr >= 0; col_ctr := col_ctr - 1)
            {
              declare ret_col any;
              declare var_name, var_type, var_strval varchar;
              declare var_pos integer;
              ret_col := ret_cols[col_ctr];
              var_name := cast (xpath_eval ('string(@name)', ret_col) as varchar);
              -- dbg_obj_princ ('var_name=', var_name);
              var_pos := position (var_name, var_list) - 1;
              if (var_pos >= 0)
                {
                  var_type := cast (xpath_eval ('local-name(*)', ret_col) as varchar);
                  var_strval := charset_recode (xpath_eval ('string(*)', ret_col), '_WIDE_', 'UTF-8');
                  -- dbg_obj_princ ('var_type=', var_type);
                  if ('uri' = var_type)
                    out_fields [var_pos] := iri_to_id (var_strval);
                  else if ('bnode' = var_type)
                    {
                      declare local_iid IRI_ID;
                      if (bnode_dict is null)
                        {
                          bnode_dict := dict_new ();
                          local_iid := iri_id_from_num (sequence_next ('RDF_URL_IID_BLANK'));
                          dict_put (bnode_dict, var_strval, local_iid);
                        }
                      else
                        {
                          local_iid := dict_get (bnode_dict, var_strval, null);
                          if (local_iid is null)
                            {
                              local_iid := iri_id_from_num (sequence_next ('RDF_URL_IID_BLANK'));
                              dict_put (bnode_dict, var_strval, local_iid);
                            }
                        }
                      out_fields [var_pos] := local_iid;
                    }
                  else if ('literal' = var_type)
                    {
                      declare lang, dt varchar;
                      lang := charset_recode (xpath_eval ('*/@xml:lang', ret_col), '_WIDE_', 'UTF-8');
                      dt := charset_recode (xpath_eval ('*/@datatype', ret_col), '_WIDE_', 'UTF-8');
                      if (res_make_obj)
                        out_fields [var_pos] := DB.DBA.RDF_MAKE_OBJ_OF_TYPEDSQLVAL_STRINGS (
                          var_strval, dt, lang );
                      else
                        out_fields [var_pos] := DB.DBA.RDF_MAKE_LONG_OF_TYPEDSQLVAL_STRINGS (
                          var_strval, dt, lang );
                    }
                  else
                    signal ('RDFZZ', sprintf (
                        'DB.DBA.SPARQL_REXEC(''%.300s'', ...) contains unsupported type of bound value ''%.300s''',
                        service, var_type ) );
                }
            }
          if (0 = res_mode)
            exec_result (out_fields);
          else if (1 = res_mode)
            vectorbld_acc (vect_acc, out_fields);
          row_inx := row_inx + 1;
          if (maxrows is not null and maxrows > 0 and row_inx >= maxrows)
            ret_row := xpath_eval ('[xmlns:rset="http://www.w3.org/2005/sparql-results#"] [xmlns:rset2="http://www.w3.org/2001/sw/DataAccess/rf1/result2"]
                                    ../rset:result[position() = last()] | ../rset2:result[position() = last()]', ret_row);
        }
      metas := vector (var_metas, 1);
      if (0 = res_mode)
        {
          return;
        }
      else if (1 = res_mode)
        {
          vectorbld_final (vect_acc);
          return vect_acc;
        }
    }
  if (ret_format = 'RDFXML')
    {
      declare res_dict any;
      res_dict := DB.DBA.RDF_RDFXML_TO_DICT (ret_body,'http://local.virt/tmp','http://local.virt/tmp');
      metas := vector (vector (vector ('res_dict', 242, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0)), 1);
      if (0 = res_mode)
        {
          result_names (res_dict);
          result (res_dict);
          return;
        }
      else if (1 = res_mode)
        return vector (vector (res_dict));
    }
  if (ret_format = 'TTL')
    {
      declare res_dict any;
      res_dict := DB.DBA.RDF_TTL2HASH (ret_body, '');
      metas := vector (vector (vector ('res_dict', 242, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0)), 1);
      if (0 = res_mode)
        {
          result_names (res_dict);
          result (res_dict);
          return;
        }
      else if (1 = res_mode)
        return vector (vector (res_dict));
    }
  if (strstr (ret_content_type, 'text/plain') is not null)
    {
      signal ('RDFZZ', sprintf (
          'DB.DBA.SPARQL_REXEC(''%.300s'', ...) returned Content-Type ''%.300s'' status ''%.300s''\n%.1000s',
          service, ret_content_type, ret_hdr[0], "LEFT" (ret_body, 1024) ) );
    }
  if (strstr (ret_content_type, 'text/html') is not null)
    {
      signal ('RDFZZ', sprintf (
          'DB.DBA.SPARQL_REXEC(''%.300s'', ...) returned Content-Type ''%.300s'' status ''%.300s''\n%.1000s',
          service, ret_content_type, ret_hdr[0],
	  "LEFT" (cast (xtree_doc (ret_body, 2) as varchar), 1024) ) );
    }
  signal ('RDFZZ', sprintf (
      'DB.DBA.SPARQL_REXEC(''%.300s'', ...) returned unsupported Content-Type ''%.300s''',
      service, ret_content_type ) );
}
;

create procedure DB.DBA.SPARQL_REXEC (
  in service varchar,
  in query varchar,
  in dflt_graph varchar,
  in named_graphs any,
  in req_hdr any,
  in maxrows integer,
  in bnode_dict any,
  in options any := null
  )
{
  declare metas any;
  DB.DBA.SPARQL_REXEC_INT (0, 0, service, query, dflt_graph, named_graphs, req_hdr, maxrows, metas, bnode_dict, options);
}
;

create function DB.DBA.SPARQL_REXEC_TO_ARRAY (
  in service varchar,
  in query varchar,
  in dflt_graph varchar,
  in named_graphs any,
  in req_hdr any,
  in maxrows integer,
  in bnode_dict any,
  in expected_var_list any := null,
  in options any := null
  ) returns any
{
  declare metas any;
  return DB.DBA.SPARQL_REXEC_INT (1, 0, service, query, dflt_graph, named_graphs, req_hdr, maxrows, metas, bnode_dict, expected_var_list, options);
}
;

create function DB.DBA.SPARQL_REXEC_TO_ARRAY_OF_OBJ (
  in service varchar,
  in query varchar,
  in dflt_graph varchar,
  in named_graphs any,
  in req_hdr any,
  in maxrows integer,
  in bnode_dict any,
  in expected_var_list any := null,
  in options any := null
  ) returns any
{
  declare metas any;
  return DB.DBA.SPARQL_REXEC_INT (1, 1, service, query, dflt_graph, named_graphs, req_hdr, maxrows, metas, bnode_dict, expected_var_list, options);
}
;

create procedure DB.DBA.SPARQL_REXEC_WITH_META (
  in service varchar,
  in query varchar,
  in dflt_graph varchar,
  in named_graphs any,
  in req_hdr any,
  in maxrows integer,
  in bnode_dict any,
  out metadata any,
  out resultset any,
  in options any := null
  )
{
  resultset := DB.DBA.SPARQL_REXEC_INT (1, 0, service, query, dflt_graph, named_graphs, req_hdr, maxrows, metadata, bnode_dict, options);
  -- dbg_obj_princ ('DB.DBA.SPARQL_REXEC_WITH_META (): metadata = ', metadata, ' resultset = ', resultset);
}
;

create procedure DB.DBA.SPARQL_SD_PROBE (in service_iri varchar, in proxy_iri varchar := null, in verbose integer := 0, in inside_resultset integer := 0)
{
  declare STAT, MSG varchar;
  declare g_iri, lang_bits_hex varchar;
  declare guess_bits, lang_bits, langex_bits, get_is_ok, post_is_ok integer;
  DB.DBA.RDF_LOG_DEBUG_INFO ('DB.DBA.SPARQL_SD_PROBE() will probe service description of SPARQL web service endpoint <%s> (proxy %s)', service_iri, coalesce (proxy_iri, 'is not used'));
  if (not inside_resultset)
    result_names (STAT, MSG);
  lang_bits := 0;
  langex_bits := 0;
  g_iri := null;
  get_is_ok := null;
  post_is_ok := null;
  if (service_iri like '%/sparql' or service_iri like '%/sparql-auth' or service_iri like '%/sparql-sd' or
    exists (sparql define input:storage ""
      prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
      ask from virtrdf: { `iri(?:service_iri)` virtrdf:dialect [] } ) )
    set_user_id ('dba');
  -- if (isstring (registry_get ('URIQADefaultHost')) and strstr (service_iri, registry_get ('URIQADefaultHost')) is not null)
  --  {
  --    DB.DBA.RDF_LOG_DEBUG_INFO ('DB.DBA.SPARQL_SD_PROBE() fails due to safety restruction: service in question, <%s>, seems to belong to the server itself ("URIQADefaultHost" registry is <%s>), HTTP connection to self may hang', service_iri, registry_get ('URIQADefaultHost'));
  --    signal ('22023', 'Can not load own service description');
  --  }
  if (exists (sparql define input:storage ""
      prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
      prefix sd: <http://www.w3.org/ns/sparql-service-description#>
      ask { graph `iri (?:service_iri)` { { ?s a sd:Service } union { ?s sd:endpoint ?ep } } } ) )
    {
      result ('00000', 'The graph <' || service_iri || '> contains old service description data, the graph will be erased first');
      sparql define input:storage "" clear graph iri (?:service_iri);
      commit work;
    }



goto get_and_post_checks;

  if (proxy_iri is not null)
  {
    sparql load iri (?:proxy_iri);
    if (not exists (sparql define input:storage "" ask where { graph `iri(?:proxy_iri)` { ?s ?p ?o }}))
      signal ('22023', 'The resource <' || proxy_iri || '> exists but does not contain any RDF data');
    if (not exists (sparql define input:storage ""
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        ask where { graph `iri(?:proxy_iri)` { ?s sd:endpoint ?o }}))
      signal ('22023', 'The resource <' || proxy_iri || '> exists but does not contain service description data');
    if (not exists (sparql define input:storage ""
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        ask where { graph `iri(?:proxy_iri)` { ?s sd:endpoint ?o }}))
      {
        result ('0000', 'The resource <' || proxy_iri || '> exists and describes some services but not the desired service <' || service_iri || '>');
        goto g_done;
      }
    g_iri := proxy_iri;
    goto g_done;
  }
  if (not (ends_with (service_iri, '-sd')))
    {
      declare sd_iri varchar;
      sd_iri := service_iri || '-sd';
      if (exists (sparql define input:storage ""
          prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
          prefix sd: <http://www.w3.org/ns/sparql-service-description#>
          ask { graph `iri (?:sd_iri)` { { ?s a sd:Service } union { ?s sd:endpoint ?ep } } }))
        {
          result ('00000', 'The graph <' || sd_iri || '> contains old service description data, the graph will be erased first');
          sparql define input:storage "" clear graph iri (?:sd_iri);
          commit work;
        }
      whenever sqlstate '*' goto no_sd;
      result ('00000', 'Trying to load <' || sd_iri || '> as a standalone service description...');
      sparql load iri (?:sd_iri);
      if (not exists (sparql define input:storage "" ask where { graph `iri(?:sd_iri)` { ?s ?p ?o }}))
        {
          result ('00000', 'The resource <' || sd_iri || '> does not contain any RDF data, ignored');
          goto no_sd;
        }
      if (not exists (sparql define input:storage ""
          prefix sd: <http://www.w3.org/ns/sparql-service-description#>
          ask where { graph `iri(?:sd_iri)` { ?s sd:endpoint ?o }}))
        {
          result ('00000', 'The resource <' || sd_iri || '> exists but does not contain service description data, ignored');
          goto no_sd;
        }
      g_iri := sd_iri;
      result ('00000', 'The resource <' || sd_iri || '> contains service description data and is used as an authoritative source');
      goto g_done;
    }
no_sd:
  if (verbose)
    result (__SQL_STATE, __SQL_MESSAGE);
  {
    whenever sqlstate '*' goto g_done;
    result ('00000', 'Trying to load <' || service_iri || '> as self-description of the service...');
    sparql load iri (?:service_iri);
    if (not exists (sparql define input:storage "" ask where { graph `iri(?:service_iri)` { ?s ?p ?o }}))
      {
        result ('00000', 'The resource <' || service_iri || '> exists but does not contain any RDF data, ignored');
        goto g_done;
      }
    if (not exists (sparql define input:storage ""
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        ask where { graph `iri(?:service_iri)` { ?s sd:endpoint ?o }}))
      {
        result ('00000', 'The resource <' || service_iri || '> exists but does not contain service description data, ignored');
        goto g_done;
      }
    g_iri := service_iri;
    goto g_done;
  }
  if (verbose)
    result (__SQL_STATE, __SQL_MESSAGE);
g_done:
  if (g_iri is not null)
    {
      declare srv_iri varchar;
      srv_iri := (sparql define input:storage ""
        prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        select ?srv where { graph `iri(?:g_iri)` { ?srv sd:endpoint `iri (?:service_iri)` } }
        order by desc (str (?srv)) limit 1 );
      if (srv_iri is null)
        {
          result ('22023', 'The resource <' || g_iri || '> is loaded but it does not contain metadata related to <' || service_iri || '> as a SPARQL web service endpoint');
          goto get_and_post_checks;
        }
      for (sparql define input:storage ""
        prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        select ?endpoint
        where { graph `iri(?:g_iri)` { `iri(?:srv_iri)` sd:endpoint ?endpoint } } ) do
        {
          sparql
          prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
          prefix sd: <http://www.w3.org/ns/sparql-service-description#>
          insert in virtrdf: { `iri(?:endpoint)` virtrdf:isEndpointOfService `iri(?:srv_iri)` };
          DB.DBA.SECURITY_CL_EXEC_AND_LOG ('jso_triple_add (?,?,?)', vector ("endpoint", UNAME'http://www.openlinksw.com/schemas/virtrdf#isEndpointOfService', srv_iri));
          result ('00000', 'The IRI <' || endpoint || '> is registered as an web service endpoint of SPARQL service <' || service_iri || '>');
        }
      declare feats any;
      feats := vector (
        'QUAD_MAP'		, 0hex0001,
        'OPTION'		, 0hex0002,
        'BREAKUP'		, 0hex0004,
        'PKSELFJOIN'		, 0hex0008,
        'RVR'			, 0hex0010,
        'IN'			, 0hex0020,
        'LIKE'			, 0hex0040,
        'GLOBALS'		, 0hex0080,
        'BI'			, 0hex0100,
        'VIRTSPECIFIC'		, 0hex0200,
        'VOS_509'		, 0hex03FF,
        'SERVICE'		, 0hex0400,
        'VOS_5_LATEST'		, 0hex0FFF,
        'TRANSIT'		, 0hex1000,
        'VOS_6'			, 0hex1FFF,
        'SPARQL11_DRAFT'	, 0hex2000,
        'SPARQL11_FULL'		, 0hex4000,
        'SPARQL11'		, 0hex6000 );
      for (sparql define input:storage ""
        prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        select (bif:subseq (str(?le), bif:length (str(virtrdf:SSG_SD_)))) as ?feat
        where { graph `iri (?:g_iri)` { { `iri(?:srv_iri)` sd:languageExtension ?le } union { `iri(?:service_iri)` sd:languageExtension ?le } } } ) do
        {
          declare bits integer;
          bits := get_keyword ("feat", feats, 0);
          lang_bits := bit_or (lang_bits, bits);
        }
      if (lang_bits = 0)
        result ('00000', 'The service metadata does not contain enough data about language capabilities, they will be probed by sample requests');
      else
        result ('00000', sprintf ('The service metadata contains data about language capabilities: equivalent of define lang:dialect %d (hex %8x)', lang_bits, lang_bits));
      feats := vector (
        'NO_GRAPH'		, 0hex0001 );
      for (sparql define input:storage ""
        prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        select (bif:subseq (str(?le), bif:length (str(virtrdf:SSG_SD_)))) as ?feat
        where { graph `iri (?:g_iri)` { { `iri(?:srv_iri)` sd:languageException ?le } union { `iri(?:service_iri)` sd:languageException ?le } } } ) do
        {
          declare bits integer;
          bits := get_keyword ("feat", feats, 0);
          langex_bits := bit_or (langex_bits, bits);
        }
      if (langex_bits <> 0)
        result ('00000', sprintf ('The service metadata contains data about language capabilities: equivalent of define lang:exceptions %d (hex %8x)', langex_bits, langex_bits));
      for (sparql define input:storage ""
        prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
        prefix sd: <http://www.w3.org/ns/sparql-service-description#>
        select ?mtd
        where { graph `iri (?:g_iri)` { `iri(?:srv_iri)` virtrdf:requestMethod ?mtd } } ) do
        {
          if ('POST' = mtd) post_is_ok := 1;
          else if ('GET' = mtd) get_is_ok := 1;
        }
    }
get_and_post_checks:
  if (get_is_ok is null and post_is_ok is null)
    {
      {
        whenever sqlstate '*' goto bad_get_endpoint;
        result ('00000', 'Trying to query <' || service_iri || '> as SPARQL web service endpoint, GET mode...');
        DB.DBA.SPARQL_REXEC_TO_ARRAY (service_iri, 'select ?s where { ?s ?p ?o } limit 1', null, null, null, 1, null, null, vector ('req_method', 'GET'));
      }
      get_is_ok := 1;
      goto get_done;
bad_get_endpoint:
      if (verbose)
        result (__SQL_STATE, __SQL_MESSAGE);
      get_is_ok := 0;
get_done: ;
      {
        whenever sqlstate '*' goto bad_post_endpoint;
        result ('00000', 'Trying to query <' || service_iri || '> as SPARQL web service endpoint, POST mode...');
        DB.DBA.SPARQL_REXEC_TO_ARRAY (service_iri, 'select ?s where { ?s ?p ?o } limit 1', null, null, null, 1, null, null, vector ('req_method', 'POST'));
      }
      post_is_ok := 1;
      goto post_done;
bad_post_endpoint:
      if (verbose)
        result (__SQL_STATE, __SQL_MESSAGE);
      post_is_ok := 0;
post_done: ;
    }
  if (get_is_ok or post_is_ok)
    {
      declare req_method varchar;
      req_method := case when (get_is_ok and post_is_ok) then null when (get_is_ok) then 'GET' when (post_is_ok) then 'POST' else null end;
      sparql
      prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
      delete from virtrdf: { `iri(?:service_iri)` virtrdf:bestRequestMethod ?o }
      from virtrdf: where { `iri(?:service_iri)` virtrdf:bestRequestMethod ?o };
      sparql
      prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
      insert in virtrdf: { `iri(?:service_iri)` virtrdf:bestRequestMethod `(?:req_method)` };
      commit work;
      DB.DBA.SECURITY_CL_EXEC_AND_LOG ('jso_triples_del (?,?,null)', vector (service_iri, UNAME'http://www.openlinksw.com/schemas/virtrdf#bestRequestMethod'));
      if (req_method is not null)
        DB.DBA.SECURITY_CL_EXEC_AND_LOG ('jso_triple_add (?,?,?)', vector (service_iri, UNAME'http://www.openlinksw.com/schemas/virtrdf#bestRequestMethod', req_method));
    }
  else
    {
      DB.DBA.RDF_LOG_DEBUG_INFO ('DB.DBA.SPARQL_SD_PROBE() has proven that the service <%s> has no description and the site is not responding as a SPARQL endpoint%s', service_iri, '');
      signal ('22023', 'The service <' || service_iri || '> has no description and the site is not responding as a SPARQL endpoint');
    }
  if (lang_bits = 0)
    {
      declare ctr, len integer;
      declare feats any;
      feats := vector (
--      qtype bits        qtxt
        '-' , 0hex0001	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o } } limit 1'																			,
        '+' , 0hex0001	, 'prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#> select ?s where { quad map virtrdf:DefaultQuadMap { ?s ?p ?o } } limit 1'													,
        '+' , 0hex0002	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o OPTION (TABLE_OPTION "ORDER") } } limit 1'															,
        '+' , 0hex0004	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o OPTION (BREAKUP) } } limit 1'																,
        '+' , 0hex0008	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o OPTION (PKSELFJOIN) } } limit 1'																,
        '+' , 0hex0010	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o OPTION (RVR) } } limit 1'																	,
        '+' , 0hex0020	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o . filter (?o in ( 1, 2, 3)) } } limit 1'															,
        '+' , 0hex0040	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o . filter (?o like "%qaz%") } } limit 1'															,
        '+' , 0hex0080	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?:oglobal } } limit 1'																		,
        '+' , 0hex0100	, 'select (str(?s) as ?str) where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o } } group by ?s limit 1'															,
        '+' , 0hex0200	, 'define input:storage "" select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o } } limit 1'																,
        '+' , 0hex0400	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> ?o } . service <http://dbpedia.org/sparql> { ?s <no-such-p-qazxswedc> ?t } } limit 1'										,
        '+' , 0hex1000	, 'select ?s where { graph <no-such-g-qazxswedc> { ?s <no-such-p-qazxswedc> <no-such-o-qazxswedc> OPTION (TRANSITIVE) } } limit 1'														,
        '+' , 0hex2000	, 'select (strdt (group_concat (?o), datatype (max(?o))) as ?gc) where { graph <no-such-g-qazxswedc> { { ?s <no-such-p-qazxswedc> ?o } MINUS { ?s <no-such-p-qazxswedc> <no-such-o-qazxswedc> } } } group by ?s having (sample(?o) > 1) limit 1'	 );
      len := length (feats) / 3;
      for (ctr := 0; ctr < len; ctr := ctr + 1)
        {
          declare qtype, qtxt varchar;
          declare bits integer;
          qtype := feats[ctr * 3];
          bits := feats[ctr * 3 + 1];
          qtxt := feats[ctr * 3 + 2];
          if (bit_and (langex_bits, 1))
            qtxt := replace (qtxt, 'graph <no-such-g-qazxswedc>', '');
          whenever sqlstate '*' goto no_such_feat;
          result ('00000', sprintf ('Test query %d/%d: %s %d (hex %08x)...', ctr, len, case qtype when '+' then 'define lang:dialect' else 'define lang:exception' end, bits, bits));
          DB.DBA.SPARQL_REXEC_TO_ARRAY (service_iri, qtxt, null, null, null, 1, null);
          if (qtype = '+')
            lang_bits := bit_or (lang_bits, bits);
          result ('00000', sprintf ('Test query %d/%d has found %s %d (hex %08x)', ctr, len, case qtype when '+' then 'support for define lang:dialect' else 'the need for define lang:exception' end, bits, bits));
          goto probe_done;
no_such_feat:
          if (verbose)
            result (__SQL_STATE, __SQL_MESSAGE);
          if (qtype = '-')
            langex_bits := bit_or (langex_bits, bits);
probe_done:;
        }
      DB.DBA.RDF_LOG_DEBUG_INFO ('DB.DBA.SPARQL_SD_PROBE() has found that the service should be used with define lang:dialect 0hex%08x define lang:exceptions 0hex%08x', lang_bits, langex_bits);
      result ('00000', sprintf ('The endpoint <' || service_iri || '> has support for define lang:dialect %d (hex %08x)', lang_bits, lang_bits));
      if (langex_bits)
        result ('00000', sprintf ('The endpoint <' || service_iri || '> needs define lang:exceptions %d (hex %08x)', langex_bits, langex_bits));
    }
  sparql define input:storage ""
  prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
  with virtrdf: delete where { `iri(?:service_iri)` ?p ?lb . filter (?p in (virtrdf:dialect, virtrdf:dialect-exceptions)) };
  lang_bits_hex := sprintf ('%08x', lang_bits);
  sparql define input:storage ""
  prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
  insert in virtrdf: { `iri(?:service_iri)` virtrdf:dialect ?:lang_bits_hex };
  DB.DBA.SECURITY_CL_EXEC_AND_LOG ('jso_triples_del (?,?,null)', vector (service_iri, UNAME'http://www.openlinksw.com/schemas/virtrdf#dialect'));
  DB.DBA.SECURITY_CL_EXEC_AND_LOG ('jso_triple_add (?,?,?)', vector (service_iri, UNAME'http://www.openlinksw.com/schemas/virtrdf#dialect', lang_bits_hex));
  lang_bits_hex := sprintf ('%08x', langex_bits);
  sparql define input:storage ""
  prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
  insert in virtrdf: { `iri(?:service_iri)` virtrdf:dialect-exceptions ?:lang_bits_hex };
  DB.DBA.SECURITY_CL_EXEC_AND_LOG ('jso_triples_del (?,?,null)', vector (service_iri, UNAME'http://www.openlinksw.com/schemas/virtrdf#dialect-exceptions'));
  DB.DBA.SECURITY_CL_EXEC_AND_LOG ('jso_triple_add (?,?,?)', vector (service_iri, UNAME'http://www.openlinksw.com/schemas/virtrdf#dialect-exceptions', lang_bits_hex));
}
;

create procedure DB.DBA.SPARQL_SINV_IMP (in ws_endpoint varchar, in ws_params any, in qtext_template varchar, in qtext_posmap nvarchar, in param_row any, in expected_vars any)
{
  declare RSET, retarray any;
  result_names (RSET);
  -- dbg_obj_princ ('DB.DBA.SPARQL_SINV_IMP (', ws_endpoint, ws_params, qtext_template, qtext_posmap, param_row, expected_vars, ')');
  if (N'' <> qtext_posmap)
    {
      declare qtext_ses any;
      declare prev_pos, qctr, qcount integer;
      qtext_ses := string_output ();
      prev_pos := 0;
      qcount := length (qtext_posmap)-1;
      for (qctr := 0; qctr < qcount; qctr := qctr+2)
        {
          declare qpos integer;
          qpos := qtext_posmap[qctr];
          http (subseq (qtext_template, prev_pos, qpos), qtext_ses);
          http_sparql_object (param_row[qtext_posmap[qctr+1]-1], qtext_ses);
          prev_pos := qpos+8;
        }
      http (subseq (qtext_template, prev_pos), qtext_ses);
      qtext_template := string_output_string (qtext_ses);
    }
  retarray := DB.DBA.SPARQL_REXEC_TO_ARRAY_OF_OBJ (
    ws_endpoint,
    qtext_template,
    NULL, --in dflt_graph varchar,
    NULL, --in named_graphs any,
    NULL, -- in req_hdr any,
    10000000,
    NULL, --  in bnode_dict any
    expected_vars );
  foreach (any retrow in retarray) do
    {
      -- dbg_obj_princ ('DB.DBA.SPARQL_SINV_IMP returns ', retrow);
      result (retrow);
    }
}
;

create procedure view DB.DBA.SPARQL_SINV_2 as DB.DBA.SPARQL_SINV_IMP (ws_endpoint, ws_params, qtext_template, qtext_posmap, param_row, expected_vars)(RSET any)
;

-----
-- SPARQL SOAP web service (incomplete, do not try to use in applications!)

create procedure "querySoap"  (in  "Command" varchar
	    , in  "Properties" any
	    , out "Error" any __soap_fault '__XML__'
	    , out "ws_sparql_xsd" any
	   )
	__soap_options ( __soap_type:='__ANY__',
                 "soapAction":='urn:FIXME:querySoap',
                 "RequestNamespace":='urn:http://www.w3.org/2005/08/sparql-protocol-query/#',
                 "ResponseNamespace":='urn:http://www.w3.org/2005/08/sparql-protocol-query/#',
                 "PartName":='return'
	       )
{
   declare stmt, state, msg, mdta, dta, res, ses any;
   stmt := get_keyword ('Statement', "Command");
   ses := string_output ();

   -- dbg_obj_princ ('Statement to be executed by querySoap: ', stmt);
   res := exec (stmt, state, msg, vector (), 0, mdta, dta);

   SPARQL_RSET_XML_WRITE_NS (ses);
   SPARQL_RESULTS_XML_WRITE_HEAD (ses, mdta);
   SPARQL_RESULTS_XML_WRITE_RES (ses, mdta, dta);

   -- dbg_obj_princ (mdta);
   http ('</sparql>', ses);

   ses := string_output_string (ses);
   string_to_file ('out.xml', ses, -2);
   res := xml_tree_doc (ses);
   return res;
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_WRITE_EXEC_STATUS (inout ses any, in line_format varchar, inout status any)
{
  declare lctr, lcount integer;
  declare lines any;
  if (status is null)
    return;
  http (sprintf (line_format, 'SQL State', status[0]), ses);
  lines := split_and_decode (status[1], 0, '\0\0\n');
  lcount := length (lines);
  for (lctr := 0; lctr < lcount; lctr := lctr + 1)
    {
      http (sprintf (line_format, case (lctr) when 0 then 'SQL Message' else '' end, lines[lctr]), ses);
    }
  http (sprintf (line_format, 'Exec Time', cast (status[2] as varchar) || ' ms'), ses);
  http (sprintf (line_format, 'DB Activity', cast (status[3] as varchar)), ses);
}
;


create procedure DB.DBA.SPARQL_RESULTS_XML_WRITE_HEAD (inout ses any, in mdta any)
{
  declare i, col_count integer;

  http ('\n <head>', ses);

  mdta := mdta[0];
  i := 0; col_count := length (mdta);
  while (i < col_count)
    {
      declare _name varchar;
      declare _type, _type_name, nill int;
      _name := mdta[i][0];
      _type := mdta[i][1];
      if (length (mdta[i]) > 4)
        nill := mdta[i][4];
      else
        nill := 0;
      http (sprintf ('\n  <variable name="%s"/>', _name), ses);
      i := i + 1;
    }
--  http (sprintf ('<link href="%s" />', 'FIX_ME'), ses);
  http ('\n </head>', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_XML_WRITE_RES (inout ses any, in mdta any, inout dta any)
{
  http ('\n <results distinct="false" ordered="true">', ses);

  for (declare ctr integer, ctr := 0; ctr < length (dta); ctr := ctr + 1)
      SPARQL_RESULTS_XML_WRITE_ROW (ses, mdta, dta[ctr]);

  http ('\n </results>', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_XML_WRITE_ROW (inout ses any, in mdta any, inout dta any)
{
  -- dbg_obj_princ ('DB.DBA.SPARQL_RESULTS_XML_WRITE_ROW (..., ',mdta, dta, ')');
  http ('\n  <result>', ses);
  mdta := mdta[0];
  for (declare x any, x := 0; x < length (mdta); x := x + 1)
    {
      declare _name varchar;
      declare _val any;
      _name := mdta[x][0];
      _val := dta[x];
      if (_val is null)
        goto end_of_binding;
      -- dbg_obj_princ ('_name=', _name, ',val=', _val, __tag(_val), __box_flags (_val));
      if (isiri_id (_val))
        {
          if (_val >= min_bnode_iri_id ())
            http (sprintf ('\n   <binding name="%s"><bnode>%s</bnode></binding>', _name, id_to_iri (_val)), ses);
          else
            {
              declare res varchar;
              res := id_to_iri (_val);
--              res := coalesce ((select RU_QNAME from DB.DBA.RDF_URL where RU_IID = _val));
              if (res is null)
                res := sprintf ('bad://%d', iri_id_num (_val));
              http (sprintf ('\n   <binding name="%s"><uri>', _name), ses);
              res := charset_recode (res, 'UTF-8', '_WIDE_');
              http_value (res, 0, ses);
              http ('</uri></binding>', ses);
            }
        }
      else if ((isstring (_val) and (bit_and (1, __box_flags (_val)))) or (__tag of UNAME = __tag (_val)))
        {
          if (_val like 'nodeID://%')
            http (sprintf ('\n   <binding name="%s"><bnode>%s</bnode></binding>', _name, _val), ses);
          else
            http (sprintf ('\n   <binding name="%s"><uri>%V</uri></binding>', _name, charset_recode (_val, 'UTF-8', '_WIDE_')), ses);
        }
      else
        {
	  declare lang, dt varchar;
	  declare is_xml_lit int;
	  declare sql_val any;
	  if (__tag (_val) = __tag of stream)
	    {
              http (sprintf ('\n   <binding name="%s"><literal>', _name), ses);
	      http_value (_val, 0, ses);
              http ('</literal></binding>', ses);
              goto end_of_binding;
	    }
	  if (__tag (_val) = __tag of XML)
	    {
              http (sprintf ('\n   <binding name="%s"><literal datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral">', _name), ses);
	      http_value (_val, 0, ses);
              http ('</literal></binding>', ses);
              goto end_of_binding;
	    }
	  lang := DB.DBA.RDF_LANGUAGE_OF_LONG (_val, null);
	  dt := DB.DBA.RDF_DATATYPE_IRI_OF_LONG (_val, null);
	  if (dt = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral')
	    is_xml_lit := 1;
	  else
            is_xml_lit := 0;
	  if (lang is not null)
	    {
	      if (dt is not null)
                http (sprintf ('\n   <binding name="%s"><literal xml:lang="%V" datatype="%V">',
		    _name, cast (lang as varchar), cast (dt as varchar)), ses);
	      else
                http (sprintf ('\n   <binding name="%s"><literal xml:lang="%V">',
		    _name, cast (lang as varchar)), ses);
	    }
	  else
	    {
	      if (dt is not null)
                http (sprintf ('\n   <binding name="%s"><literal datatype="%V">',
		    _name, cast (dt as varchar)), ses);
	      else
                http (sprintf ('\n   <binding name="%s"><literal>',
		    _name), ses);
	    }
	  sql_val := __rdf_sqlval_of_obj (_val, 1);
 	  if (isinteger (sql_val) and dt = 'http://www.w3.org/2001/XMLSchema#boolean')
 	    {
 	       if (sql_val = 0)
                 sql_val := 'false';
                else
                 sql_val := 'true';
 	    }
	  if (__tag of rdf_box = __tag (_val) and __tag of datetime = rdf_box_data_tag (_val))
	    {
	      __rdf_long_to_ttl (_val, ses);
	    }
	  else
	    {
	      if (isentity (sql_val))
		is_xml_lit := 1;
	      if (__tag (sql_val) = __tag of varchar) -- UTF-8 value kept in a DV_STRING box
		sql_val := charset_recode (sql_val, 'UTF-8', '_WIDE_');
	      if (is_xml_lit) http ('<![CDATA[', ses);
	      http_value (__rdf_strsqlval (sql_val), 0, ses);
	      if (is_xml_lit) http (']]>', ses);
	    }
          http ('</literal></binding>', ses);
        }
end_of_binding: ;
    }

  http ('\n  </result>', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_NS (inout ses any)
{
  http ('<rdf:RDF xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:nodeID="rset">
    <rdf:type rdf:resource="http://www.w3.org/2005/sparql-results#ResultSet" />', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_HEAD (inout ses any, in mdta any)
{
  declare i, col_count integer;
  mdta := mdta[0];
  i := 0; col_count := length (mdta);
  while (i < col_count)
    {
      declare _name varchar;
      declare _type, _type_name, nill int;
      _name := mdta[i][0];
      _type := mdta[i][1];
      if (length (mdta[i]) > 4)
        nill := mdta[i][4];
      else
        nill := 0;
      http (sprintf ('\n    <res:resultVariable>%V</res:resultVariable>', _name), ses);
      i := i + 1;
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_RES (inout ses any, in mdta any, inout dta any)
{
  for (declare ctr integer, ctr := 0; ctr < length (dta); ctr := ctr + 1)
    {
      http ( sprintf ('\n    <res:solution rdf:nodeID="r%d">', ctr), ses);
      SPARQL_RESULTS_RDFXML_WRITE_ROW (ses, mdta, dta, ctr);
      http ('\n    </res:solution>', ses);
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_ROW (inout ses any, in mdta any, inout dta any, in rowno integer)
{
  -- dbg_obj_princ ('DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_ROW (..., {', dta[rowno], '},...)');
  mdta := mdta[0];
  for (declare x any, x := 0; x < length (mdta); x := x + 1)
    {
      declare _name varchar;
      declare _val any;
      _name := mdta[x][0];
      _val := dta[rowno][x];
      if (_val is null)
        goto end_of_binding;
      http (sprintf ('\n      <res:binding rdf:nodeID="r%dc%d"><res:variable>%V</res:variable><res:value', rowno, x, _name), ses);
      if (isiri_id (_val))
        {
          if (_val >= min_bnode_iri_id ())
            {
              http (sprintf (' rdf:nodeID="b%s"/></res:binding>', id_to_iri (_val)), ses);
            }
          else
            {
              declare res varchar;
              res := id_to_iri (_val);
--              res := coalesce ((select RU_QNAME from DB.DBA.RDF_URL where RU_IID = _val));
              if (res is null)
                res := sprintf ('bad://%d', iri_id_num (_val));
              http (sprintf (' rdf:resource="%V"/></res:binding>', charset_recode (res, 'UTF-8', '_WIDE_')), ses);
            }
        }
      else if ((isstring (_val) and (1 = __box_flags (_val))) or (__tag of UNAME = __tag (_val)))
        {
          if (_val like 'nodeID://%')
            http (sprintf (' rdf:nodeID="b%s"/></res:binding>', subseq(_val, 9)), ses);
          else
            http (sprintf (' rdf:resource="%V"/></res:binding>', charset_recode (_val, 'UTF-8', '_WIDE_')), ses);
        }
      else
        {
          declare lang, dt varchar;
          declare val_tag integer;
          val_tag := __tag (_val);
          if (val_tag = __tag of stream)
            {
                     http ('>', ses);
              http_value (_val, 0, ses);
                     http ('</res:value></res:binding>', ses);
                     goto end_of_binding;
            }
          if (val_tag = __tag of XML)
            {
                     http (' rdf:parseType="Literal">', ses);
              http_value (_val, 0, ses);
              http ('</res:value></res:binding>', ses);
              goto end_of_binding;
            }
          lang := DB.DBA.RDF_LANGUAGE_OF_LONG (_val, null);
          dt := DB.DBA.RDF_DATATYPE_IRI_OF_LONG (_val, null);
          if (lang is not null)
            {
              if (dt is not null)
                       http (sprintf (' xml:lang="%V" datatype="%V">', cast (lang as varchar), cast (dt as varchar)), ses);
              else
                       http (sprintf (' xml:lang="%V">', cast (lang as varchar)), ses);
            }
          else
            {
              if (dt is not null)
                       http (sprintf (' datatype="%V">', cast (dt as varchar)), ses);
              else
                       http ('>', ses);
            }
                 if (__tag of datetime = rdf_box_data_tag (_val))
                   __rdf_long_to_ttl (_val, ses);
                 else
            {
              _val := __rdf_sqlval_of_obj (_val, 1);
              if (__tag (_val) = __tag of varchar) -- UTF-8 value kept in a DV_STRING box
                _val := charset_recode (_val, 'UTF-8', '_WIDE_');
              http_value (__rdf_strsqlval (_val), 0, ses);
            }
          http ('</res:value></res:binding>', ses);
        }
end_of_binding: ;
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_TTL_WRITE_NS (inout ses any)
{
  http ('@prefix res: <http://www.w3.org/2005/sparql-results#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
_:_ a res:ResultSet .\n', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_TTL_WRITE_HEAD (inout ses any, in mdta any)
{
  declare i, col_count integer;
  mdta := mdta[0];
  i := 0; col_count := length (mdta);
  if (0 = col_count)
    return;
  http ('_:_ res:resultVariable "', ses);
  while (i < col_count)
    {
      declare _name varchar;
      declare _type, _type_name, nill int;
      _name := mdta[i][0];
      _type := mdta[i][1];
      if (length (mdta[i]) > 4)
        nill := mdta[i][4];
      else
        nill := 0;
      http_escape (_name, 11, ses, 0, 1);
      i := i + 1;
      if (i < col_count)
        http ('" , "', ses);
    }
  http ('" .\n', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_TTL_WRITE_RES (inout ses any, in mdta any, inout dta any)
{
  declare colctr, colcount, rowctr, len, fake_agg_ctx integer;
  declare cols, colbuf, env any;
  cols := mdta[0];
  colcount := length (cols);
  colbuf := make_array (colcount * 7, 'any');
  len := length (dta);
  for (colctr := 0; colctr < colcount; colctr := colctr + 1)
    {
      colbuf [colctr * 7] := cols[colctr][0];
    }
  env := DB.DBA.RDF_TRIPLES_TO_TTL_ENV (__min (len * 3, 16000), 0, colbuf, ses);
  rowctr := 0;
  while (rowctr < len)
    {
      declare r any;
      r := aref_set_0 (dta, rowctr);
      sparql_rset_ttl_write_row (fake_agg_ctx, env, r);
      aset_zap_arg (dta, rowctr, r);
      rowctr := rowctr + 1;
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_NT_WRITE_NS (inout ses any)
{
  http ('_:ResultSet2053 rdf:type <http://www.w3.org/1999/02/22-rdf-syntax-ns#res:ResultSet> .\n', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_NT_WRITE_HEAD (inout ses any, in mdta any)
{
  declare i, col_count integer;
  mdta := mdta[0];
  i := 0; col_count := length (mdta);
  while (i < col_count)
    {
      declare _name varchar;
      declare _type, _type_name, nill int;
      _name := mdta[i][0];
      _type := mdta[i][1];
      if (length (mdta[i]) > 4)
        nill := mdta[i][4];
      else
        nill := 0;
      http ('_:ResultSet2053 <http://www.w3.org/2005/sparql-results#resultVariable> "', ses);
      http_escape (_name, 11, ses, 0, 1);
      http ('" .\n', ses);
      i := i + 1;
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_NT_WRITE_RES (inout ses any, in mdta any, inout dta any)
{
  declare colctr, colcount, rowctr, len, fake_agg_ctx integer;
  declare cols, colbuf, env any;
  cols := mdta[0];
  colcount := length (cols);
  colbuf := make_array (colcount * 7, 'any');
  len := length (dta);
  for (colctr := 0; colctr < colcount; colctr := colctr + 1)
    {
      colbuf [colctr * 7] := cols[colctr][0];
    }
  env := vector (0, colbuf, ses);
  rowctr := 0;
  while (rowctr < len)
    {
      declare r any;
      r := aref_set_0 (dta, rowctr);
      sparql_rset_nt_write_row (fake_agg_ctx, env, r);
      aset_zap_arg (dta, rowctr, r);
      rowctr := rowctr + 1;
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_JAVASCRIPT_HTML_WRITE (inout ses any, inout metas any, inout rset any, in is_js integer := 0, in esc_mode integer := 1, in pure_html integer := 0)
{
  declare varctr, varcount, resctr, rescount integer;
  declare trnewline, newline varchar;
  varcount := length (metas[0]);
  rescount := length (rset);
  if (esc_mode = 13)
    {
      newline := '';
      trnewline := ''');\ndocument.writeln(''';
    }
  else
    newline := trnewline := '\n';
  if (is_js)
    {
      http ('document.writeln(''', ses);
      SPARQL_RESULTS_JAVASCRIPT_HTML_WRITE(ses,metas,rset,0,13);
      http (''');', ses);
      return;
   }
  http ('<table class="table table-striped table-sm table-borderless">', ses);
  http (trnewline || '  <tr>', ses);
  --http ('\n    <th>Row</th>', ses);
  for (varctr := 0; varctr < varcount; varctr := varctr + 1)
    {
      http(newline || '    <th>', ses);
      http_escape (metas[0][varctr][0], esc_mode, ses, 0, 1);
      http('</th>', ses);
    }
  http (newline || '  </tr>', ses);
  for (resctr := 0; resctr < rescount; resctr := resctr + 1)
    {
      http(trnewline || '  <tr>', ses);
      --http('\n    <td>', ses);
      --http(cast((resctr + 1) as varchar), ses);
      --http('</td>', ses);
      for (varctr := 0; varctr < varcount; varctr := varctr + 1)
        {
          declare val any;
          val := rset[resctr][varctr];
          if (val is null)
            {
              http(newline || '    <td></td>', ses);
              goto end_of_val_print; -- see below
            }
          http(newline || '    <td>', ses);
          if (isiri_id (val))
            {
              if (is_js or is_bnode_iri_id (val))
                http_escape (id_to_iri (val), esc_mode, ses, 1, 1);
              else
                {
                  http ('<a href="', ses);
                  http_escape (id_to_iri (val), 3, ses, 1, 1);
                  http ('">', ses);
                  http_escape (id_to_iri (val), esc_mode, ses, 1, 1);
                  http ('</a>', ses);
                }
            }
          else if ((isstring (val) and (1 = __box_flags (val))) or (__tag of UNAME = __tag (val)))
            {
              if (is_js or val='' or (val[0]=95) or (val like 'nodeID://%'))
                http_escape (val, esc_mode, ses, 1, 1);
              else
                {
                  http ('<a href="', ses);
                  http_escape (val, 3, ses, 1, 1);
                  http ('">', ses);
                  http_escape (val, esc_mode, ses, 1, 1);
                  http ('</a>', ses);
                }
            }
          else if (__tag of varchar = __tag (val))
            {
              http ('<pre>', ses);
              http_escape (val, esc_mode, ses, 1, 1);
              http ('</pre>', ses);
            }
	  else if (__tag of stream = __tag (val))
	    {
              http ('<pre>', ses);
              http_escape (cast (val as varchar), esc_mode, ses, 1, 1);
              http ('</pre>', ses);
	    }
	  else if (__tag of XML = rdf_box_data_tag (val))
	    {
              --if (is_js)
                --{
                  declare tmpses any;
                  tmpses := string_output();
                  http_value (val, 0, tmpses);
                  http_escape (cast (tmpses as varchar), esc_mode, ses, 1, 1);
                --}
              --else
                --http_value (val, 0, ses);
            }
          else if (pure_html and __tag of rdf_box = __tag (val))
            {
              http ('<pre>', ses);
              http_rdf_object (val, ses, 1);
              http ('</pre>', ses);
            }
          else
            {
              http ('<pre>', ses);
              http_escape (__rdf_strsqlval (val), esc_mode, ses, 1, 1);
              http ('</pre>', ses);
            }
          http ('</td>', ses);
end_of_val_print: ;
        }
      http(newline || '  </tr>', ses);
    }
  http (trnewline || '</table>', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_JSON_WRITE_BINDING (inout ses any, in colname varchar, inout val any)
{
  http(' "', ses);
  http_escape (colname, 14, ses, 0, 1);
  http('": { ', ses);
  if (isiri_id (val))
    {
      if (val > min_bnode_iri_id ())
        http (sprintf ('"type": "bnode", "value": "%s', id_to_iri (val)), ses);
      else
        {
          http ('"type": "uri", "value": "', ses);
          http_escape (id_to_iri (val), 14, ses, 1, 1);
        }
    }
  else if (__tag of rdf_box = __tag (val))
    {
      declare res varchar;
      declare dat, typ any;
      dat := __rdf_sqlval_of_obj (val, 1);
      typ := rdf_box_type (val);
      if (not isstring (dat))
        {
          http ('"type": "typed-literal", "datatype": "', ses);
          if (257 <> typ)
            res := coalesce ((select RDT_QNAME from DB.DBA.RDF_DATATYPE where RDT_TWOBYTE = typ));
          else
            res := cast (__xsd_type (dat) as varchar);
          http_escape (res, 14, ses, 1, 1);
          http ('", "value": "', ses);
          dat := __rdf_strsqlval (dat);
        }
      else if (257 <> typ)
        {
          http ('"type": "typed-literal", "datatype": "', ses);
          res := coalesce ((select RDT_QNAME from DB.DBA.RDF_DATATYPE where RDT_TWOBYTE = typ));
          http_escape (res, 14, ses, 1, 1);
          http ('", "value": "', ses);
        }
      else if (257 <> rdf_box_lang (val))
        {
          http ('"type": "literal", "xml:lang": "', ses);
          res := coalesce ((select RL_ID from DB.DBA.RDF_LANGUAGE where RL_TWOBYTE = rdf_box_lang (val)));
          http_escape (res, 14, ses, 1, 1);
          http ('", "value": "', ses);
        }
      else
        http ('"type": "literal", "value": "', ses);
      if (__tag of datetime = rdf_box_data_tag (val))
	__rdf_long_to_ttl (val, ses);
      else
	http_escape (dat, 14, ses, 1, 1);
    }
  else if (__tag of varchar = __tag (val))
    {
      if (bit_and (1, __box_flags (val)))
        {
          if (val like 'nodeID://%')
            http (sprintf ('"type": "bnode", "value": "%s', val), ses);
          else
            {
              http ('"type": "uri", "value": "', ses);
              http_escape (val, 14, ses, 1, 1);
            }
        }
      else
        {
          http ('"type": "literal", "value": "', ses);
          http_escape (val, 14, ses, 1, 1);
        }
    }
  else if (__tag of UNAME = __tag (val))
    {
      if (val like 'nodeID://%')
        http (sprintf ('"type": "bnode", "value": "%s', val), ses);
      else
        {
          http ('"type": "uri", "value": "', ses);
          http_escape (val, 14, ses, 1, 1);
        }
    }
  else if (__tag of varbinary = __tag (val))
    {
      http ('"type": "literal", "value": "', ses);
      http_escape (val, 14, ses, 0, 0);
    }
  else if (__tag of stream = __tag (val))
    {
      http ('"type": "literal", "value": "', ses);
      http_escape (cast (val as varchar), 14, ses, 1, 1);
    }
  else if (__tag of XML = __tag (val))
    {
      http ('"type": "literal", "value": "', ses);
      http_escape (serialize_to_UTF8_xml (val), 14, ses, 1, 1);
    }
  else
    {
      http ('"type": "typed-literal", "datatype": "', ses);
      http_escape (cast (__xsd_type (val) as varchar), 14, ses, 1, 1);
      http ('", "value": "', ses);
      http_escape (__rdf_strsqlval (val), 14, ses, 1, 1);
    }
  http ('" }', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_JSON_WRITE (inout ses any, inout metas any, inout rset any)
{
  declare varctr, varcount, resctr, rescount integer;
  varcount := length (metas[0]);
  rescount := length (rset);
  http ('\n{ "head": { "link": [], "vars": [', ses);
  for (varctr := 0; varctr < varcount; varctr := varctr + 1)
    {
      if (varctr > 0)
        http(', "', ses);
      else
        http('"', ses);
      http_escape (metas[0][varctr][0], 14, ses, 0, 1);
      http('"', ses);
    }
  http ('] },\n  "results": { "distinct": false, "ordered": true, "bindings": [', ses);
  for (resctr := 0; resctr < rescount; resctr := resctr + 1)
    {
      declare need_comma integer;
      if (resctr > 0)
        http(',\n    {', ses);
      else
        http('\n    {', ses);
      need_comma := 0;
      for (varctr := 0; varctr < varcount; varctr := varctr + 1)
        {
          declare val any;
          val := rset[resctr][varctr];
          if (val is null)
            goto end_of_val_print; -- see below
          if (need_comma)
            http('\t,', ses);
          else
            need_comma := 1;
          SPARQL_RESULTS_JSON_WRITE_BINDING (ses, metas[0][varctr][0], val);
end_of_val_print: ;
        }
      http('}', ses);
    }
  http (' ] } }', ses);
}
;

create procedure DB.DBA.SPARQL_RESULTS_CSV_WRITE (inout ses any, inout metas any, inout rset any)
{
  declare varctr, varcount, resctr, rescount integer;
  varcount := length (metas[0]);
  rescount := length (rset);
  for (varctr := 0; varctr < varcount; varctr := varctr + 1)
    {
      if (varctr > 0)
        http(',', ses);
      DB.DBA.SPARQL_RESULTS_CSV_WRITE_VALUE (ses, metas[0][varctr][0]);
    }
  http ('\n', ses);
  for (resctr := 0; resctr < rescount; resctr := resctr + 1)
    {
      for (varctr := 0; varctr < varcount; varctr := varctr + 1)
        {
          declare val any;
          val := rset[resctr][varctr];
          if (varctr > 0)
            http(',', ses);
          if (val is not null)
            DB.DBA.SPARQL_RESULTS_CSV_WRITE_VALUE (ses, val);
        }
      http('\n', ses);
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_TSV_WRITE (inout ses any, inout metas any, inout rset any)
{
  declare varctr, varcount, resctr, rescount integer;
  varcount := length (metas[0]);
  rescount := length (rset);
  for (varctr := 0; varctr < varcount; varctr := varctr + 1)
    {
      if (varctr > 0)
        http('\t', ses);
      DB.DBA.SPARQL_RESULTS_CSV_WRITE_VALUE (ses, metas[0][varctr][0]);
    }
  http ('\n', ses);
  for (resctr := 0; resctr < rescount; resctr := resctr + 1)
    {
      for (varctr := 0; varctr < varcount; varctr := varctr + 1)
        {
          declare val any;
          val := rset[resctr][varctr];
          if (varctr > 0)
            http('\t', ses);
          if (val is not null)
            DB.DBA.SPARQL_RESULTS_CSV_WRITE_VALUE (ses, val);
        }
      http('\n', ses);
    }
}
;

create procedure DB.DBA.SPARQL_RESULTS_HTML_TR_WRITE (inout ses any, inout metas any, inout rset any, in esc_mode integer := 1)
{
  declare varctr, varcount, resctr, rescount, ctr integer;
  declare describe_path, about_path varchar;
  declare nsdict, nslist any;
  varcount := length (metas[0]);
  rescount := length (rset);
  describe_path := about_path := null;
  if (DB.DBA.VAD_CHECK_VERSION ('fct') is not null)
    describe_path := '/describe/?url=';
  else if (DB.DBA.VAD_CHECK_VERSION ('cartridges') is not null)
    about_path := '/about/html/';
  nsdict := dict_new (10 + cast (sqrt (0.3e0 * varcount * rescount) as integer));
  --dict_put (nsdict, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'rdf');
  --dict_put (nsdict, 'http://www.w3.org/2001/XMLSchema#', 'xsdh');

  http ('<table class="table table-striped table-sm table-borderless">', ses);
  http ('\n  <tr>', ses);
  --http('\n    <th>Row #</th>', ses);
  for (varctr := 0; varctr < varcount; varctr := varctr + 1)
    {
      http('\n    <th>', ses);
      http_escape (metas[0][varctr][0], 1, ses, 0, 1);
      http('</th>', ses);
    }
  http ('\n  </tr>', ses);
  for (resctr := 0; resctr < rescount; resctr := resctr + 1)
    {
      for (varctr := 0; varctr < varcount; varctr := varctr + 1)
        id_to_iri_nosignal (rset[resctr][varctr]);
    }
  for (resctr := 0; resctr < rescount; resctr := resctr + 1)
        {
      http('\n  <tr>', ses);
      --http('\n    <td>', ses); http(cast((resctr + 1) as varchar), ses); http('</td>', ses);
      for (varctr := 0; varctr < varcount; varctr := varctr + 1)
        {
          declare val, split any;
          val := rset[resctr][varctr];
          if (val is null)
            {
              http('\n    <td></td>', ses);
              goto end_of_val_print; -- see below
            }
          http('\n    <td>', ses);
          if (isiri_id (val))
            {
              if (is_bnode_iri_id (val))
                http_escape (id_to_iri (val), 1, ses, 1, 1);
              else
                {
                  val := id_to_iri (val);
                  goto iri_print; -- see below;
                }
            }
          else if ((isstring (val) and (1 = __box_flags (val))) or (__tag of UNAME = __tag (val)))
            {
              if (val='' or (val[0]=95) or (val like 'nodeID://%'))
                http_escape (val, 1, ses, 1, 1);
              else
                goto iri_print; -- see below;
            }
          else if (__tag of varchar = __tag (val))
            {
              http ('<pre>', ses);
              http_escape (val, 1, ses, 1, 1);
              http ('</pre>', ses);
            }
	  else if (__tag of stream = __tag (val))
	    {
              http ('<pre>', ses);
              http_escape (cast (val as varchar), 1, ses, 1, 1);
              http ('</pre>', ses);
	    }
	  else if (__tag of XML = rdf_box_data_tag (val))
	    {
              declare tmpses any;
              tmpses := string_output();
              http_value (val, 0, tmpses);
              http_escape (cast (tmpses as varchar), 1, ses, 1, 1);
            }
          else if (__tag of rdf_box = __tag (val))
            {
              http ('<pre>', ses);
              http_rdf_object (val, ses, 1);
              http ('</pre>', ses);
            }
          else
            {
              http ('<pre>', ses);
              http_escape (__rdf_strsqlval (val), 1, ses, 1, 1);
              http ('</pre>', ses);
            }
          http ('</td>', ses);
          goto end_of_val_print; -- see below

iri_print:
-- If you want to print QNames instead of full IRIs, uncomment this and comment out the IFs below:
--          split := sparql_iri_split_rdfa_qname (val, nsdict, 2);
--          if (describe_path is not null)
--            {
--              if ('' = split[1])		http (sprintf ('\n<a href="%s%U">%V</a></td>'		, describe_path, val, split[2]		)	, ses);
--              else if (isstring (split[0]))	http (sprintf ('\n<a href="%s%U">%V:%V</a></td>'	, describe_path, val, split[0], split[2])	, ses);
--              else				http (sprintf ('\n<a href="%s%U">%V%V</a></td>'		, describe_path, val, split[1], split[2])	, ses);
--            }
--          else if (about_path is not null)
--            {
--              if ('' = split[1])		http (sprintf ('\n<a href="%s%U">%V</a></td>'		, about_path, val, split[2]		)	, ses);
--              else if (isstring (split[0]))	http (sprintf ('\n<a href="%s%U">%V:%V</a></td>'	, about_path, val, split[0], split[2]	)	, ses);
--              else				http (sprintf ('\n<a href="%s%U">%V%V</a></td>'		, about_path, val, split[1], split[2]	)	, ses);
--            }
--          else
--            {
--              if ('' = split[1])		http (sprintf ('\n<a href="%U">%V</a></td>'	, val, split[2])		, ses);
--              else if (isstring (split[0]))	http (sprintf ('\n<a href="%U">%V:%V</a></td>'	, val, split[0], split[2])	, ses);
--              else				http (sprintf ('\n<a href="%U">%V%V</a></td>'	, val, split[1], split[2])	, ses);
--            }

          http ('<a href="', ses);
          if (describe_path is not null)
            {
	      http (describe_path, ses);
	      http_escape (val, 6, ses, 1, 1);	-- encode as parameter
            }
          else
            {
	      if (about_path is not null)
	          http(about_path, ses);
	      http_escape (val, 3, ses, 1, 1);  -- normal encode
	  }
	  http ('">', ses);
	  http_escape (val, esc_mode, ses, 1, 1);
	  http ('</a>', ses);

end_of_val_print: ;
        }
      http('\n  </tr>', ses);
    }
  http ('\n</table>', ses);
  if (dict_size (nsdict))
    {
      http ('\n<table><tr><th>Prefix</th><th>Namespace IRI</th></tr>', ses);
      nslist := dict_to_vector (nsdict, 0);
      for (ctr := length (nslist) - 2; ctr >= 0; ctr := ctr-2)
        {
          http (sprintf ('\n<tr><td>%V</td><td>%V</td></tr>', nslist[ctr+1], nslist[ctr]), ses);
        }
      http ('</table>', ses);
    }
}
;

--!AWK PUBLIC
create function DB.DBA.SPARQL_LOG_DEBUG_INFO (inout log_array any, in line_begin varchar, in line_end varchar, inout ses any)
{
  -- dbg_obj_princ ('DB.DBA.SPARQL_LOG_DEBUG_INFO (', log_array, line_begin, line_end, ',...)');
  declare ctr, len integer;
  len := length (log_array);
  ctr := 0;
  while (ctr < len)
    {
      declare line varchar;
        {
          whenever sqlstate '*' goto sprintf_err;
          line := sprintf (log_array[ctr][0], log_array[ctr][1], log_array[ctr][2]);
        }
      goto line_is_ready;
sprintf_err:
      line := sprintf ('(internal error in logging SPARQL diagnostics, failed message is "%s")', log_array[ctr][0]);
line_is_ready:
      if (strstr (line, '\n') is not null)
        line := replace (line, '\n', '[[LF]]');
      if (strstr (line, '\r') is not null)
        line := replace (line, '\r', '[[CR]]');
      -- dbg_obj_princ ('Line ', ctr, '/', len, ': ', line);
      http (line_begin, ses);
      http (line, ses);
      http (line_end, ses);
find_next_line:
      if ((ctr >= 4) and (log_array[ctr][0] = log_array[ctr-1][0]) and (log_array[ctr][0] = log_array[ctr-2][0]) and (log_array[ctr][0] = log_array[ctr-3][0]) and (log_array[ctr][0] = log_array[ctr-4][0])
        and ((ctr+2) < len) and (log_array[ctr][0] = log_array[ctr+1][0]) and (log_array[ctr][0] = log_array[ctr+2][0]) )
        {
          declare next_ctr integer;
          next_ctr := ctr + 3;
          while ((next_ctr < len) and (log_array[next_ctr][0] = log_array[ctr][0]))
            next_ctr := next_ctr + 1;
          http (line_begin, ses);
          http (sprintf ('(%d similar messages are skipped)', next_ctr - (ctr+1)), ses);
          http (line_end, ses);
          ctr := next_ctr;
        }
      else
        ctr := ctr + 1;
    }
}
;


--
-- Generate Content-Disposition header hint to browsers
--
create procedure DB.DBA.SPARQL_CONTENT_DISPOSITION (in fmt varchar, in att integer := 0)
{
  declare hdr varchar;
  declare suffix varchar;
  declare slist any;
  declare ctr, len integer;

  --  NOTE: ordering is important
  slist := vector (
    'ATOM%'		, '.atom',
    'CSV'		, '.csv',
    'CXML%'		, '.cxml',
    'HTML%'		, '.html',
    'JS'		, '.js',
    'JSON;LD%'		, '.jsonld',
    'JSON%'		, '.json',
    'NICE_TTL'		, '.ttl',
    'NT'		, '.nt',
    'RDFA%'		, '.rdfa',
    'RDFXML'		, '.rdf',
    'SOAP'		, '.soap',
    'TRIG'		, '.trig',
    'TSV'		, '.tsv',
    'TTL'		, '.ttl',
    'XML'		, '.xml'
  );
  len := length(slist);

  suffix := '.txt';
  for (ctr := 0; ctr < len; ctr := ctr + 2) {
     if (fmt like slist[ctr]) {
	suffix := slist[ctr + 1];
	goto found_match;
     }
  }

found_match:
  hdr := 'Content-disposition: ';
  if (att)
    hdr := hdr || 'attachement; ';
  hdr := hdr || 'filename=' || strftime ('sparql_%Y-%m-%d_%H-%M-%SZ', curutcdatetime()) || suffix || '\r\n';

  http_header (coalesce (http_header_get (), '') || hdr);
}
;


--! \c flags is bitmask: 1 to add HTTP headers, 2 to dump the log of debug info composed by RDF_LOG_DEBUG_INFO in current connection, there may be more in the future
create function DB.DBA.SPARQL_RESULTS_WRITE (inout ses any, inout metas any, inout rset any, in accept varchar, in flags integer, in status any := null) returns varchar
{
  declare singlefield varchar;
  declare ret_mime, ret_format varchar;
  if (status is not null)
    {
      http_header (concat (coalesce (http_header_get (), ''),
          'X-SQL-State: ', status[0], '\r\nX-SQL-Message: ', status[1],
          '\r\nX-Exec-Milliseconds: ', cast (status[2] as varchar), '\r\nX-Exec-DB-Activity: ', cast (status[3] as varchar),
          '\r\n' ) );
    }
  if ((1 >= length (rset)) and (1 = length (metas[0])))
    singlefield := metas[0][0][0];
  else
    singlefield := NULL;
  -- dbg_obj_princ ('DB.DBA.SPARQL_RESULTS_WRITE: length(rset) = ', length(rset), ' metas=', metas, ' singlefield=', singlefield, ' accept=', accept, ' flags=', flags);
  if ('__ask_retval' = singlefield)
    {
      declare ask_result int;
      ask_result := 0;
      if (length (rset) = 1 and length (rset[0]) = 1 and rset[0][0] > 0)
        ask_result := 1;
      ret_mime := http_sys_find_best_sparql_accept (accept, 0, ret_format);
      if (ret_format in ('JSON', 'JSON;RES'))
        {
          http (
            concat (
              '{  "head": { "link": [] }, "boolean": ',
              case (ask_result) when 0 then 'false' else 'true' end,
              '}'),
            ses );
        }
      else if (ret_format = 'XML')
        {
          SPARQL_RSET_XML_WRITE_NS (ses);
          http (
            concat (
              '\n <head></head>\n <boolean>',
              case (ask_result) when 0 then 'false' else 'true' end,
              '</boolean>\n</sparql>'),
            ses );
        }
      else if (ret_format = 'TTL')
        {
          http ('@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .\n@prefix rs: <http://www.w3.org/2005/sparql-results#> .\n', ses);
          http (sprintf ('[] rdf:type rs:results ; rs:boolean %s .', case (ask_result) when 0 then 'false' else 'true' end), ses);
        }
      else if (ret_format = 'CSV' or ret_format = 'TSV')
        {
          http (sprintf ('"bool"\n%d\n', case (ask_result) when 0 then 0 else 1 end), ses);
        }
      else
        {
          ret_mime := 'text/html';
          http (case (ask_result) when 0 then 'false' else 'true' end, ses); --- stub
        }
      goto body_complete;
    }
  if ((1 = length (rset)) and
    (1 = length (rset[0])) and
    (__tag of dictionary reference = __tag (rset[0][0])) )
    {
      declare triples any;
      triples := dict_list_keys (rset[0][0], 1);
      ret_mime := http_sys_find_best_sparql_accept (accept, 1, ret_format);
      if ((ret_format is null) or (ret_format = 'TTL'))
        {
          if (ret_format is null)
            ret_mime := 'text/turtle';
          DB.DBA.RDF_TRIPLES_TO_TTL (triples, ses);
          if (status is not null)
            SPARQL_WRITE_EXEC_STATUS (ses, '#%015s: %s\n', status);
	}
      else if (ret_format = 'TRIG')
        DB.DBA.RDF_TRIPLES_TO_TRIG (triples, ses);
      else if (ret_format = 'NT')
        DB.DBA.RDF_TRIPLES_TO_NT (triples, ses);
      else if (ret_format in ('JSON', 'JSON;TALIS'))
        DB.DBA.RDF_TRIPLES_TO_TALIS_JSON (triples, ses);
      else if (ret_format = 'JSON;LD')
        DB.DBA.RDF_TRIPLES_TO_JSON_LD (triples, ses);
      else if (ret_format = 'JSON;LD_CTX')
        DB.DBA.RDF_TRIPLES_TO_JSON_LD_CTX (triples, ses);
      else if (ret_format = 'JSON;RES')
        DB.DBA.RDF_TRIPLES_TO_JSON (triples, ses);
      else if (ret_format = 'RDFA;XHTML')
        DB.DBA.RDF_TRIPLES_TO_RDFA_XHTML (triples, ses);
      else if (ret_format = 'HTML;UL')
	{
          DB.DBA.RDF_TRIPLES_TO_HTML_UL (triples, ses);
	  ret_mime := 'text/html';
	}
      else if (ret_format = 'HTML;TR')
	{
          DB.DBA.RDF_TRIPLES_TO_HTML_TR (triples, ses);
	  ret_mime := 'text/html';
	}
      else if (ret_format = 'HTML;MICRODATA')
	{
          DB.DBA.RDF_TRIPLES_TO_HTML_MICRODATA (triples, ses);
	  ret_mime := 'text/html';
	}
      else if (ret_format = 'HTML;NICE_MICRODATA')
	{
          DB.DBA.RDF_TRIPLES_TO_HTML_NICE_MICRODATA (triples, ses);
	  ret_mime := 'text/html';
	}
      else if (ret_format = 'JSON;MICRODATA')
        DB.DBA.RDF_TRIPLES_TO_JSON_MICRODATA (triples, ses);
      else if (ret_format = 'ATOM;XML')
        DB.DBA.RDF_TRIPLES_TO_ATOM_XML_TEXT (triples, 1, ses);
      else if (ret_format = 'JSON;ODATA')
        DB.DBA.RDF_TRIPLES_TO_ODATA_JSON (triples, ses);
      else if (ret_format = 'CXML')
        DB.DBA.RDF_TRIPLES_TO_CXML (triples, ses, accept, bit_and (flags, 1), 0, status);
      else if (ret_format = 'CXML;QRCODE')
        DB.DBA.RDF_TRIPLES_TO_CXML (triples, ses, accept, bit_and (flags, 1), 1, status);
      else if (ret_format = 'CSV')
        DB.DBA.RDF_TRIPLES_TO_CSV (triples, ses);
      else if (ret_format = 'TSV')
        DB.DBA.RDF_TRIPLES_TO_TSV (triples, ses);
      else if (ret_format = 'NICE_TTL')
        {
          DB.DBA.RDF_TRIPLES_TO_NICE_TTL (triples, ses);
          ret_mime := 'text/turtle';
        }
      else if (ret_format = 'HTML;NICE_TTL')
        {
          DB.DBA.RDF_TRIPLES_TO_HTML_NICE_TTL (triples, ses);
          ret_mime := 'text/html';
        }
      else if (ret_format = 'SOAP')
	{
	  declare soap_ns, spt_ns varchar;
	  declare soap_ver int;

	  if (strstr (accept, 'application/soap+xml;11') is not null)
	    soap_ver := 11;
	  else
	    soap_ver := 12;
	  soap_ns := DB.DBA.SPARQL_SOAP_NS (soap_ver);
	  spt_ns := DB.DBA.SPARQL_PT_NS ();
	  if (soap_ver = 12)
	    ret_mime := 'application/soap+xml';
	  else
	    ret_mime := 'text/xml';
	  http ('<soapenv:Envelope xmlns:soapenv="'||soap_ns||'"><soapenv:Body><query-result xmlns="'||spt_ns||'">', ses);
          http ('<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" '||
      			'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">', ses);
          DB.DBA.RDF_TRIPLES_TO_RDF_XML_TEXT (triples, 0, ses);
	  http ('</rdf:RDF>', ses);
	  http ('</query-result></soapenv:Body></soapenv:Envelope>', ses);
	}
      else if (ret_format = 'HTML;SCRIPT_TTL')
        {
          DB.DBA.RDF_TRIPLES_TO_HTML_SCRIPT_TTL (triples, ses);
          ret_mime := 'text/html';
        }
      else if (ret_format = 'HTML;SCRIPT_LD_JSON')
        {
          DB.DBA.RDF_TRIPLES_TO_HTML_SCRIPT_LD_JSON (triples, ses);
          ret_mime := 'text/html';
        }
      else
        {
          ret_mime := 'application/rdf+xml';
          DB.DBA.RDF_TRIPLES_TO_RDF_XML_TEXT (triples, 1, ses);
        }
      goto body_complete;
    }
  ret_mime := http_sys_find_best_sparql_accept (accept, 0, ret_format);
  if (ret_format in ('JSON', 'JSON;RES'))
    {
      if ((singlefield like 'fmtaggret-HTTP+RDF/XML%') or (singlefield like 'fmtaggret-HTTP+TURTLE-0%') or (singlefield like 'fmtaggret-HTTP+TTL-0%'))
        {
          http('"', ses);
          http_escape (cast (rset[0][0] as varchar), 11, ses, 1, 1);
          http('"', ses);
        }
      else
        SPARQL_RESULTS_JSON_WRITE (ses, metas, rset);
      goto body_complete;
    }
  if ((singlefield like 'fmtaggret-HTTP+RDF/XML%') and ('auto' = accept))
    {
      ret_mime := 'application/rdf+xml';
      http (rset[0][0], ses);
      goto body_complete;
    }
  if ((singlefield like 'fmtaggret-HTTP+TURTLE%') or (singlefield like 'fmtaggret-HTTP+TTL%'))
    {
      if ((ret_format = 'TTL') or (ret_format is null))
        {
          if (ret_format is null)
            ret_mime := 'text/turtle';
        }
      http (rset[0][0], ses);
      if (status is not null)
        SPARQL_WRITE_EXEC_STATUS (ses, '#%015s: %s\n', status);
      goto body_complete;
    }
  if (singlefield like 'fmtaggret-%')
    {
      declare ws_pos integer;
      ws_pos := strchr (singlefield, ' ');
      if (ws_pos is not null)
        ret_mime := subseq (singlefield, ws_pos + 1);
      -- dbg_obj_princ ('fmtaggret selected ', ret_mime, ret_format, ' for ', rset[0][0]);
--      if (not (singlefield like 'fmtaggret-HTTP+%'))
        http (rset[0][0], ses);
      goto body_complete;
    }
  if (ret_format = 'HTML')
    {
      if (bit_and (flags, 1))
        WS.WS.SPARQL_RESULT_HTML5_OUTPUT_BEGIN ('HTML5 table', ses);
      SPARQL_RESULTS_JAVASCRIPT_HTML_WRITE(ses, metas, rset, 0, 1, case when ret_mime = 'text/html' then 1 else 0 end);
      if (bit_and (flags, 1))
        WS.WS.SPARQL_RESULT_HTML5_OUTPUT_END (ses);
      goto body_complete;
    }
  if (ret_format = 'JS')
    {
      SPARQL_RESULTS_JAVASCRIPT_HTML_WRITE(ses, metas, rset, 1);
      goto body_complete;
    }
  if (ret_format = 'SOAP')
    {
      declare soap_ns, spt_ns varchar;
      declare soap_ver int;

      if (strstr (accept, 'application/soap+xml;11') is not null)
        soap_ver := 11;
      else
        soap_ver := 12;
      soap_ns := DB.DBA.SPARQL_SOAP_NS (soap_ver);
      spt_ns := DB.DBA.SPARQL_PT_NS ();
      if (soap_ver = 12)
        ret_mime := 'application/soap+xml';
      else
        ret_mime := 'text/xml';
      http ('<soapenv:Envelope xmlns:soapenv="'||soap_ns||'"><soapenv:Body><query-result xmlns="'||spt_ns||'">', ses);
      SPARQL_RSET_XML_WRITE_NS (ses);
      SPARQL_RESULTS_XML_WRITE_HEAD (ses, metas);
      SPARQL_RESULTS_XML_WRITE_RES (ses, metas, rset);
      http ('\n</sparql>', ses);
      http ('</query-result></soapenv:Body></soapenv:Envelope>', ses);
      goto body_complete;
    }
  if ((ret_format = 'TTL') or (ret_format = 'NICE_TTL'))
    {
      if (ret_format is null)
        ret_mime := 'text/turtle';
      SPARQL_RESULTS_TTL_WRITE_NS (ses);
      SPARQL_RESULTS_TTL_WRITE_HEAD (ses, metas);
      SPARQL_RESULTS_TTL_WRITE_RES (ses, metas, rset);
      goto body_complete;
    }
  if (ret_format = 'NT')
    {
      SPARQL_RESULTS_NT_WRITE_NS (ses);
      SPARQL_RESULTS_NT_WRITE_HEAD (ses, metas);
      SPARQL_RESULTS_NT_WRITE_RES (ses, metas, rset);
      goto body_complete;
    }
  if (ret_format = 'RDFXML')
    {
      ret_mime := 'application/rdf+xml';
      SPARQL_RESULTS_RDFXML_WRITE_NS (ses);
      SPARQL_RESULTS_RDFXML_WRITE_HEAD (ses, metas);
      SPARQL_RESULTS_RDFXML_WRITE_RES (ses, metas, rset);
      http ('\n  </rdf:Description>', ses);
      http ('\n</rdf:RDF>', ses);
      goto body_complete;
    }
  if ((ret_format = 'CXML') or (ret_format = 'CXML;QRCODE'))
    {
      DB.DBA.SPARQL_RESULTS_CXML_WRITE(ses, metas, rset, accept, bit_and (flags, 1), status);
      goto body_complete;
    }
  if (ret_format = 'CSV')
    {
      ret_mime := 'text/csv';
      DB.DBA.SPARQL_RESULTS_CSV_WRITE (ses, metas, rset);
      goto body_complete;
    }
  if (ret_format = 'TSV')
    {
      ret_mime := 'text/tab-separated-values';
      DB.DBA.SPARQL_RESULTS_TSV_WRITE (ses, metas, rset);
      goto body_complete;
    }
  if (ret_format = 'HTML;TR')
    {
      ret_mime := 'text/html';
      WS.WS.SPARQL_RESULT_HTML5_OUTPUT_BEGIN ('HTML5 table (faceted browsing links)', ses);
      DB.DBA.SPARQL_RESULTS_HTML_TR_WRITE (ses, metas, rset);
      WS.WS.SPARQL_RESULT_HTML5_OUTPUT_END (ses);
      goto body_complete;
    }
  ret_mime := 'application/sparql-results+xml';
  SPARQL_RSET_XML_WRITE_NS (ses);
  SPARQL_RESULTS_XML_WRITE_HEAD (ses, metas);
  SPARQL_RESULTS_XML_WRITE_RES (ses, metas, rset);
  http ('\n</sparql>', ses);

body_complete:
  if (bit_and (flags, 2))
    {
      declare line_begin, line_end varchar;
      declare log_array any;
      log_array := 0;
      if (connection_get ('DB.DBA.RDF_LOG_DEBUG_INFO', 0))
        connection_swap ('DB.DBA.RDF_LOG_DEBUG_INFO acc', log_array, -1);
      if (__tag(log_array) <> __tag of vector)
        log_array := vector (vector ('The debug log has no messages. The most probable reason is that the query has no sponging or similar activity.', '', ''));
      else
        vectorbld_final (log_array);
      if (ret_format like 'HTML%')
        {
          line_begin := '<!-' || '- '; line_end := '-' || '->';
        }
      else if (ret_format in ('SOAP', 'RDFXML', 'CXML', 'CXML;QRCODE'))
        {
          line_begin := '<!-' || '- '; line_end := '-' || '->';
        }
      else if (ret_format in ('TTL', 'NICE_TTL', 'NT'))
        {
          line_begin := '# '; line_end := '';
        }
      else
        line_begin := null;
      if (line_begin is not null)
        DB.DBA.SPARQL_LOG_DEBUG_INFO (log_array, line_begin, line_end, ses);
    }

  DB.DBA.SPARQL_CONTENT_DISPOSITION (ret_format);

  if (bit_and (flags, 1) and strcasestr (http_header_get (), 'Content-Type:') is null)
    http_header (coalesce (http_header_get (), '') || 'Content-Type: ' || ret_mime || case when strstr (ret_mime, 'json') is null then '; charset=UTF-8' else '' end || '\r\n');
  return ret_mime;
}
;

-- CLIENT --
--select -- dbg_obj_princ (soap_client (url=>'http://neo:6666/SPARQL', operation=>'querySoap', target_namespace=>'urn:FIXME', soap_action =>'urn:FIXME:querySoap', parameters=> vector ('Command', soap_box_structure ('Statement' , 'select TEST from DB.DBA.SPARQL_TABLE3'), 'Properties', soap_box_structure ('PropertyList', 'None' )), style=>2));

create procedure WS.WS.SPARQL_ENDPOINT_SVC_DESC ()
{
  declare ses any;
  ses := string_output ();
  http ('    <div style="display:none">\n', ses);
  http ('       <div class="description" about="" typeof="sd:Service">\n', ses);
  http (sprintf ('          <div rel="sd:endpoint" resource="%s://%{WSHost}s/sparql"></div>\n',
		case when is_https_ctx () then 'https' else 'http' end, ses), ses);
  http ('          <div rel="sd:feature"\n', ses);
  http ('               resource="http://www.w3.org/ns/sparql-service-description#UnionDefaultGraph"></div>\n', ses);
  http ('          <div rel="sd:feature"\n', ses);
  http ('               resource="http://www.w3.org/ns/sparql-service-description#DereferencesURIs"></div>\n', ses);
  http ('          <div rel="sd:resultFormat" resource="http://www.w3.org/ns/formats/RDF_XML"></div>\n', ses);
  http ('          <div rel="sd:resultFormat" resource="http://www.w3.org/ns/formats/Turtle"></div>\n', ses);
  http ('          <div rel="sd:resultFormat"\n', ses);
  http ('               resource="http://www.w3.org/ns/formats/SPARQL_Results_CSV"></div>\n', ses);
  http ('          <div rel="sd:resultFormat" resource="http://www.w3.org/ns/formats/N-Triples"></div>\n', ses);
  http ('          <div rel="sd:resultFormat" resource="http://www.w3.org/ns/formats/N3"></div>\n', ses);
  http ('          <div rel="sd:resultFormat"\n', ses);
  http ('               resource="http://www.w3.org/ns/formats/SPARQL_Results_JSON"></div>\n', ses);
  http ('          <div rel="sd:resultFormat" resource="http://www.w3.org/ns/formats/RDFa"></div>\n', ses);
  http ('          <div rel="sd:resultFormat"\n', ses);
  http ('               resource="http://www.w3.org/ns/formats/SPARQL_Results_XML"></div>\n', ses);
  http ('          <div rel="sd:supportedLanguage"\n', ses);
  http ('               resource="http://www.w3.org/ns/sparql-service-description#SPARQL10Query"></div>\n', ses);
  http (sprintf ('          <div rel="sd:url" resource="%s://%{WSHost}s/sparql"></div>\n',
		case when is_https_ctx () then 'https' else 'http' end, ses), ses);
  http ('       </div>\n', ses);
  http ('    </div>\n', ses);
  return ses;
}
;


create procedure WS.WS.SPARQL_VHOST_RESET ()
{
  declare gr varchar;
  declare oopts any;
  oopts := null;
  if (not exists (select 1 from "DB"."DBA"."SYS_USERS" where U_NAME = 'SPARQL'))
    {
      DB.DBA.USER_CREATE ('SPARQL', uuid(), vector ('DISABLED', 1, 'LOGIN_QUALIFIER', 'SPARQL'));
      DB.DBA.EXEC_STMT ('grant SPARQL_SELECT to "SPARQL"', 0);
    }
  if (registry_get ('__SPARQL_VHOST_RESET') >= '20120519')
    return;

  DB.DBA.VHOST_REMOVE (lpath=>'/SPARQL');
  DB.DBA.VHOST_REMOVE (lpath=>'/services/sparql-query');

  oopts := (select deserialize (HP_OPTIONS) from HTTP_PATH
  	where HP_PPATH = '/!sparql/' and HP_LPATH = '/sparql' and HP_HOST = '*ini*' and HP_LISTEN_HOST = '*ini*');
  if (oopts is null) oopts := vector ('noinherit', 1);
  DB.DBA.VHOST_REMOVE (lpath=>'/sparql');
  DB.DBA.VHOST_DEFINE (lpath=>'/sparql/', ppath => '/!sparql/', is_dav => 1, vsp_user => 'dba', opts => oopts);
  DB.DBA.VHOST_REMOVE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql');
  DB.DBA.VHOST_DEFINE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql/', ppath => '/!sparql/', is_dav => 1, vsp_user => 'dba', opts => oopts);

  oopts := (select deserialize (HP_OPTIONS) from HTTP_PATH
  	where HP_PPATH = '/!sparql-graph-crud/' and HP_LPATH = '/sparql-graph-crud' and HP_HOST = '*ini*' and HP_LISTEN_HOST = '*ini*');
  if (oopts is null) oopts := vector ('noinherit', 1, 'exec_as_get', 1);
  DB.DBA.VHOST_REMOVE (lpath=>'/sparql-graph-crud');
  DB.DBA.VHOST_DEFINE (lpath=>'/sparql-graph-crud/', ppath => '/!sparql-graph-crud/', is_dav => 1, vsp_user => 'dba', opts => oopts);
  DB.DBA.VHOST_REMOVE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-graph-crud');
  DB.DBA.VHOST_DEFINE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-graph-crud/', ppath => '/!sparql-graph-crud/', is_dav => 1, vsp_user => 'dba', opts => oopts);

  oopts := (select deserialize (HP_OPTIONS) from HTTP_PATH
  	where HP_PPATH = '/!sparql/' and HP_LPATH = '/sparql-auth' and HP_HOST = '*ini*' and HP_LISTEN_HOST = '*ini*');
  if (oopts is null) oopts := vector ('noinherit', 1);
  DB.DBA.VHOST_REMOVE (lpath=>'/sparql-auth');
  DB.DBA.VHOST_DEFINE (lpath=>'/sparql-auth',
    ppath => '/!sparql/',
    is_dav => 1,
    vsp_user => 'dba',
    opts => oopts,
    auth_fn=>'DB.DBA.HP_AUTH_SPARQL_USER',
    realm=>'SPARQL',
    sec=>'digest');
  DB.DBA.VHOST_REMOVE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-auth');
  DB.DBA.VHOST_DEFINE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-auth',
    ppath => '/!sparql/',
    is_dav => 1,
    vsp_user => 'dba',
    opts => oopts,
    auth_fn=>'DB.DBA.HP_AUTH_SPARQL_USER',
    realm=>'SPARQL',
    sec=>'digest');

  oopts := (select deserialize (HP_OPTIONS) from HTTP_PATH
  	where HP_PPATH = '/!sparql-graph-crud/' and HP_LPATH = '/sparql-graph-crud-auth' and HP_HOST = '*ini*' and HP_LISTEN_HOST = '*ini*');
  if (oopts is null) oopts := vector ('noinherit', 1, 'exec_as_get', 1);
  DB.DBA.VHOST_REMOVE (lpath=>'/sparql-graph-crud-auth');
  DB.DBA.VHOST_DEFINE (lpath=>'/sparql-graph-crud-auth',
    ppath => '/!sparql-graph-crud/',
    is_dav => 1,
    vsp_user => 'dba',
    opts => oopts,
    auth_fn=>'DB.DBA.HP_AUTH_SPARQL_USER',
    realm=>'SPARQL',
    sec=>'digest');
  DB.DBA.VHOST_REMOVE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-graph-crud-auth');
  DB.DBA.VHOST_DEFINE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-graph-crud-auth',
    ppath => '/!sparql-graph-crud/',
    is_dav => 1,
    vsp_user => 'dba',
    opts => oopts,
    auth_fn=>'DB.DBA.HP_AUTH_SPARQL_USER',
    realm=>'SPARQL',
    sec=>'digest');

--DB.DBA.EXEC_STMT ('grant execute on DB.."querySoap" to "SPARQL", 0);
--VHOST_DEFINE (lpath=>'/services/sparql-query', ppath=>'/SOAP/', soap_user=>'SPARQL',
--              soap_opts => vector ('ServiceName', 'XMLAnalysis', 'elementFormDefault', 'qualified'));
  DB.DBA.VHOST_REMOVE (lpath=>'/sparql-sd');
  DB.DBA.VHOST_DEFINE (lpath=>'/sparql-sd/', ppath => '/!sparql-sd/', is_dav => 1, vsp_user => 'dba', opts => vector('noinherit', 1));
  DB.DBA.VHOST_REMOVE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-sd');
  DB.DBA.VHOST_DEFINE (vhost=>'*sslini*', lhost=>'*sslini*', lpath=>'/sparql-sd/', ppath => '/!sparql-sd/', is_dav => 1, vsp_user => 'dba', opts => vector('noinherit', 1));

  gr := concat ('http://', registry_get ('URIQADefaultHost'), '/sparql');
  DB.DBA.RDF_LOAD_RDFA (WS.WS.SPARQL_ENDPOINT_SVC_DESC (), gr, gr);
  registry_set ('__SPARQL_VHOST_RESET', '20120519');
}
;


-----
-- SPARQL HTTP request handler
create procedure DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (
  inout path varchar, inout params any, inout lines any,
  in httpcode varchar, in httpstatus varchar,
  in query varchar, in state varchar, in msg varchar, in accept varchar := null)
{
  -- dbg_obj_princ ('DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (...', httpcode, httpstatus, '...', state, msg, accept);
--  declare exit handler for sqlstate '*' { signal (state, msg); };
  if (httpstatus is null)
    {
      declare errtitle varchar;
      declare delim varchar;
      delim := strchr (msg, '\n');
      if (delim is null)
        errtitle := msg;
      else
        errtitle := subseq (msg, 0, delim);
      httpstatus := sprintf ('Error %s %s', state, errtitle);
    }
  if (accept is not null and strstr (accept, 'application/soap+xml') is not null)
    {
      declare err_str any;
      declare soap_ver int;
      if (strstr (accept, 'application/soap+xml;11') is not null)
	{
	  soap_ver := 11;
	  http_header ('Content-Type: text/xml; charset=UTF-8\r\n');
	}
      else
	{
          soap_ver := 12;
	  http_header ('Content-Type: application/soap+xml; charset=UTF-8\r\n');
	}
      http_request_status (sprintf ('HTTP/1.1 500 %s', httpstatus));
      err_str := soap_make_error ('320', state, msg, soap_ver);
      http (err_str);
      return;
    }
  http_request_status (sprintf ('HTTP/1.1 %s %s', httpcode, httpstatus));
  http_header ('Content-Type: text/plain\r\n');
  http (concat ('Virtuoso ', state, ' Error ', msg));
  if (query is not null)
    {
      http ('\n\nSPARQL query:\n');
      http (query);
    }
}
;

create procedure DB.DBA.SPARQL_WSDL11 (in lines any)
{
  declare host, _http  any;
  host := http_request_header (lines, 'Host', null, null);
  _http := case when is_https_ctx() then 'https' else 'http' end;
    http (sprintf ('<?xml version="1.0" encoding="utf-8"?>
    <definitions xmlns="http://schemas.xmlsoap.org/wsdl/"
		 xmlns:tns="http://www.w3.org/2005/08/sparql-protocol-query/#"
		 targetNamespace="http://www.w3.org/2005/08/sparql-protocol-query/#">
    <import namespace="http://www.w3.org/2005/08/sparql-protocol-query/#"
    location="http://www.w3.org/TR/sprot11/sparql-protocol-query-11.wsdl"/>
      <service name="SparqlService">
        <port name="SparqlServicePort" binding="tns:QuerySoapBinding">
	  <address location="%s://%s/sparql"/>
	</port>
      </service>
    </definitions>', _http, host));
}
;

create procedure DB.DBA.SPARQL_WSDL (in lines any)
{
  declare host, _http  any;
  host := http_request_header (lines, 'Host', null, null);
  _http := case when is_https_ctx() then 'https' else 'http' end;
  
    http (sprintf ('<?xml version="1.0" encoding="utf-8"?>
    <description xmlns="http://www.w3.org/2006/01/wsdl"
		 xmlns:tns="http://www.w3.org/2005/08/sparql-protocol-query/#"
		 targetNamespace="http://www.w3.org/2005/08/sparql-protocol-query/#">
      <include location="http://www.w3.org/TR/rdf-sparql-protocol/sparql-protocol-query.wsdl" />
      <service name="SparqlService" interface="tns:SparqlQuery">
	<endpoint name="SparqlEndpoint" binding="tns:querySoap" address="%s://%s/sparql"/>
      </service>
    </description>', _http, host));
}
;

create procedure DB.DBA.SPARQL_SOAP_NS (in ver int)
{
  if (ver = 11)
    return 'http://schemas.xmlsoap.org/soap/envelope/';
  else if (ver = 12)
    return 'http://www.w3.org/2003/05/soap-envelope';
  else
    signal ('42000', 'Un-supported SOAP version');
}
;

create procedure DB.DBA.SPARQL_PT_NS ()
{
  return 'http://www.w3.org/2005/09/sparql-protocol-types/#';
}
;

--!AWK PUBLIC
create function DB.DBA.PARSE_SPARQL_WS_PARAMS (in lst any) returns any
{
  declare pval, parse, res any;
  declare lst_len, ctr integer;
  declare pname, ttl_txt varchar;
  lst_len := length (lst);
  ttl_txt := '';
  vectorbld_init (res);
  for (ctr := 0; ctr < lst_len; ctr := ctr+2)
    {
      pname := lst[ctr];
      pval := lst[ctr+1];
      if (regexp_like (pval, '^(("[^"\\\\]")|(\'[^\'\\\\]\'))\044'))
        parse := subseq (pval, 1, length (pval)-1);
      else if (regexp_like (pval, '^(("""[^"\\\\]""")|(\'\'\'[^\'\\\\]\'\'\'))\044'))
        parse := subseq (pval, 3, length (pval)-3);
      else if (regexp_like ('^<.+>\044', pval))
        {
          parse := (subseq (pval, 1, length (pval)-1));
          __box_flags_set (parse, 1);
        }
      else if (regexp_like (pval, '^([+-]?[0-9]+)\044'))
        parse := cast (pval as integer);
      else if (regexp_like (pval, '^([+-]?[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?)\044'))
        parse := cast (pval as double precision);
      else
        {
          parse := null;
          ttl_txt := concat (ttl_txt, '<', pname, '> <p> ', pval, ' .\n');
        }
      if (parse is not null)

        vectorbld_acc (res, ':' || pname, parse);
    }
  if (ttl_txt <> '')
    {
      declare triples any;
      triples := DB.DBA.RDF_TTL2SQLHASH (ttl_txt, '', '!sparql', 0);
      triples := dict_list_keys (triples, 1);
      foreach (any t in triples) do
        {
          vectorbld_acc (res, ':' || t[0], t[2]);
        }
    }
  vectorbld_final (res);
  return res;
}
;

create procedure DB.DBA.rdf_find_str (in x any)
{
  return cast (x as varchar);
}
;

grant execute on DB.DBA.rdf_find_str to public
;



-- Web service endpoint.
create procedure WS.WS."/!sparql/" (inout path varchar, inout params any, inout lines any)
{
  declare query, full_query, md5_of_full_query, signed_query_to_exec, format, quiet_geo, should_sponge, signal_void, signal_unconnected, log_debug_info, def_qry varchar;
  declare dflt_graphs, named_graphs, using_graphs, using_named_graphs any;
  declare paramctr, paramcount, qry_params, maxrows, can_sponge,  start_time integer;
  declare ses, content any;
  declare def_max, add_http_headers, hard_timeout, timeout, client_supports_partial_res, sp_ini, soap_ver int;
  declare http_meth, content_type, ini_dflt_graph, get_user, jsonp_callback varchar;
  declare reported_unknown_services any;
  declare state, msg varchar;
  declare metas, rset any;
  declare accept, soap_action, user_id varchar;
  declare exec_time, exec_db_activity any;
  declare __debug_mode integer;
  declare qtxt, deadl integer;
  declare save_mode, save_dir, dav_refresh, overwrite, fname varchar;
  declare explain_report varchar;
  declare save_dir_id any;
  declare help_topic varchar;
  -- dbg_obj_princ ('===============');
  -- dbg_obj_princ ('===============');
  -- dbg_obj_princ ('===============');
  -- dbg_obj_princ ('WS.WS."/!sparql/" (', path, params, lines, ')');
  for (declare i int, i := 0; i < length (params); i := i + 2)
    {
      declare vn, vv varchar;
      vn := params[i];
      vv := params[i+1];
      if (not (isstring (vv)) or (vv <> ''))
        connection_set ('SPARQL_' || vn, vv);
    }
  if (registry_get ('__sparql_endpoint_debug') = '1')
    {
      __debug_mode := 1;
      for (declare i int, i := 0; i < length (params); i := i + 2)
        {
	  if (isstring (params[i+1]))
	    dbg_printf ('%s=%s',params[i],params[i+1]);
	  else if (__tag (params[i+1]) = __tag of stream)
	    dbg_printf ('%s=%s',params[i],'<strses>');
	  else
	    dbg_printf ('%s=%s',params[i],'<box>');
	}
    }

  set http_charset='utf-8';
  http_methods_set ('OPTIONS', 'GET', 'HEAD', 'POST', 'TRACE');
  ses := 0;
  signal_void := '';
  signal_unconnected := '';
  quiet_geo := '';
  log_debug_info := '';
  query := null;
  format := '';
  should_sponge := '';
  add_http_headers := 1;
  sp_ini := 0;
  dflt_graphs := vector ();
  named_graphs := vector ();
  using_graphs := vector ();
  using_named_graphs := vector ();
  maxrows := 1024*1024; -- More than enough for web-interface.
  deadl := 0;
  http_meth := http_request_get ('REQUEST_METHOD');
  ini_dflt_graph := virtuoso_ini_item_value ('SPARQL', 'DefaultGraph');
  hard_timeout := atoi (coalesce (virtuoso_ini_item_value ('SPARQL', 'MaxQueryExecutionTime'), '0')) * 1000;
  timeout := atoi (coalesce (virtuoso_ini_item_value ('SPARQL', 'ExecutionTimeout'), '0')) * 1000;
  client_supports_partial_res := 0;

  user_id := connection_get ('SPARQLUserId', 'SPARQL');
  help_topic := get_keyword ('help', params, null);
  if (help_topic is not null)
    {
      WS.WS.SPARQL_ENDPOINT_BRIEF_HELP (path, params, lines, user_id, help_topic);
      return;
    }

  def_qry := get_keyword('qtxt', params, '');
  ini_dflt_graph := get_keyword ('default-graph-uri', params, ini_dflt_graph);
  timeout := atoi (get_keyword ('timeout', params, cast (timeout as varchar)));
  explain_report := get_keyword ('explain', params, '');

  if ('' <> def_qry)
    qtxt := 1;
  def_max := atoi (coalesce (virtuoso_ini_item_value ('SPARQL', 'ResultSetMaxRows'), '-1'));

  -- Get the max values as specified by the client but always stick to the system-wide max if there is any
  if (not connection_get ('SPARQL/MaxQueryExecutionTime') is null)
    hard_timeout := __min (cast (connection_get ('SPARQL/MaxQueryExecutionTime') as int) * 1000, hard_timeout);
  if (not connection_get ('SPARQL/ResultSetMaxRows') is null)
    def_max := __min (cast (connection_get ('SPARQL/ResultSetMaxRows') as int), def_max);

  -- if timeout specified and it's over 1 second

  save_dir := trim (get_keyword ('dname', params, ''));
  save_dir_id := DAV_SEARCH_ID (save_dir, 'C');
  if (DAV_HIDE_ERROR (save_dir_id) is null)
  	save_dir := null;

  fname := trim (get_keyword ('fname', params, ''));
  if (fname = '')
    fname := null;

  dav_refresh := get_keyword ('dav_refresh', params, '');
  if (dav_refresh = '')
    dav_refresh := null;

  overwrite := get_keyword ('dav_overwrite', params, '0');
  if (overwrite <> '0')
    overwrite := '1';

  save_mode := get_keyword ('save', params, '');

  if (save_mode = '' OR save_mode = 'display') {
    save_mode := null;
    dav_refresh := null;
    fname := null;
  } else if (save_mode = 'dynamic' OR dav_refresh is not null) {
    save_mode := 'dynamic';
    dav_refresh := '1';
  } else {
    save_mode := 'tmpstatic';
    dav_refresh := null;
  }

  get_user := '';
  soap_ver := 0;
  soap_action := http_request_header (lines, 'SOAPAction', null, null);
  content_type := http_request_header (lines, 'Content-Type', null, '');

  if (content_type = 'application/soap+xml')
    soap_ver := 12;
  else if (soap_action is not null)
    soap_ver := 11;

  if (content_type = 'application/sparql-update')
    {
      declare b any;
      b := http_body_read ();
      query := string_output_string (b);
      paramcount := length (params);
      if (paramcount = 0 or (((2 = paramcount) and ('Content' = params[0])) and soap_ver = 0))
	goto execute_query;
    }

  content := null;
  declare exit handler for sqlstate '*' {
    DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
      '500', 'SPARQL Request Failed',
      query, __SQL_STATE, __SQL_MESSAGE, format);
     return;
   };

  -- the WSDL
  if (http_path () = '/sparql/services.wsdl')
    {
      http_header ('Content-Type: application/wsdl+xml\r\n');
--      http_header ('Content-Type: text/xml\r\n');
      DB.DBA.SPARQL_WSDL (lines);
      return;
    }
  else if (http_path () = '/sparql/services11.wsdl')
    {
      http_header ('Content-Type: text/xml\r\n');
      DB.DBA.SPARQL_WSDL11 (lines);
      return;
    }

  if (__debug_mode) dbg_printf ('%d', soap_ver);

  if (get_keyword ('nsdecl', params) is not null)
    {
      WS.WS.SPARQL_ENDPOINT_BRIEF_HELP (path, params, lines, user_id, 'nsdecl');
      return;
    }
  if (get_keyword ('rdfinf', params) is not null)
    {
      WS.WS.SPARQL_ENDPOINT_BRIEF_HELP (path, params, lines, user_id, 'rdfinf');
      return;
    }

  can_sponge := coalesce ((select top 1 1
      from DB.DBA.SYS_USERS as sup
        join DB.DBA.SYS_ROLE_GRANTS as g on (sup.U_ID = g.GI_SUPER)
        join DB.DBA.SYS_USERS as sub on (g.GI_SUB = sub.U_ID)
      where sup.U_NAME = 'SPARQL' and sub.U_NAME = 'SPARQL_SPONGE' ), 0);

  paramcount := length (params);

  if ((0 = paramcount) or
      (((2 = paramcount) and ('Content' = params[0])) and soap_ver = 0) or
      qtxt = 1)
    {
       declare redir, acc varchar;
       redir := registry_get ('WS.WS.SPARQL_DEFAULT_REDIRECT');
       if (isstring (redir))
         {
            http_request_status ('HTTP/1.1 301 Moved Permanently');
            http_header (sprintf ('Location: %s\r\n', redir));
            return;
         }
      if (not qtxt)
        {
          def_qry := virtuoso_ini_item_value ('SPARQL', 'DefaultQuery');
          if (def_qry is null)
            def_qry := 'SELECT * WHERE {?s ?p ?o}';
        }

      if (qtxt <> 1)
	{
	  acc := DB.DBA.HTTP_RDF_GET_ACCEPT_BY_Q (http_request_header_full (lines, 'Accept', '*/*'));
	  if (strstr (acc, '/rdf+xml') is not null or strstr (acc, 'text/n3') is not null or strstr (acc, 'text/turtle') is not null)
	    {
	       query := sprintf ('construct { ?s ?p ?o } from <http://%s/sparql> { ?s ?p ?o }', registry_get ('URIQADefaultHost'));
	       accept := acc;
	       goto execute_query;
	    }
	}
      signal_void := get_keyword ('signal_void', params, '1');
      signal_unconnected := get_keyword ('signal_unconnected', params, '1');
      quiet_geo := get_keyword ('quiet_geo', params, '');
      if ('' <> get_keyword ('debug', params, ''))
        signal_void := signal_unconnected := '1';
      log_debug_info := get_keyword ('log_debug_info', params, '');
      WS.WS.SPARQL_ENDPOINT_GENERATE_FORM(params, ini_dflt_graph, def_qry, timeout, signal_void, signal_unconnected, quiet_geo, log_debug_info, save_mode, dav_refresh, overwrite, explain_report);
      return;
    }

execute_query:
  qry_params := dict_new (7);
  for (paramctr := 0; paramctr < paramcount; paramctr := paramctr + 2)
    {
      declare pname, pvalue varchar;
      pname := params [paramctr];
      pvalue := params [paramctr+1];
      if (pname in ('query', 'update'))
        query := pvalue;
      else if ('find' = pname)
	{
	  declare cls, words, ft, vec, cond varchar;
	  cls := get_keyword ('class', params);
	  maxrows := atoi (get_keyword ('maxrows', params, cast (maxrows as varchar)));
	  if (def_max > 0 and def_max < maxrows)
	    maxrows := def_max;
	  if (cls is not null)
	    cond := sprintf (' ?s a %s . ', cls);
          else
	    cond := '';
	  ft := trim (DB.DBA.FTI_MAKE_SEARCH_STRING_INNER (pvalue, words), '()');
          if (ft is null or length (words) = 0)
            {
              DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
                '400', 'Bad Request',
                query, '22023', 'The value of "find" parameter of web service endpoint is not a valid search string' );
              return;
            }
	  vec := DB.DBA.SYS_SQL_VECTOR_PRINT (words);
	  if (get_keyword ('format', params, '') like '%/rdf+%' or http_request_header (lines, 'Accept', null, '') like '%/rdf+%')
	    query := sprintf ('construct { ?s ?p `bif:search_excerpt (bif:vector (%s), sql:rdf_find_str(?o))` } ' ||
	    'where { ?s ?p ?o . %s filter (bif:contains (?o, ''%s'')) } limit %d', vec, cond, ft, maxrows);
	  else
	    query := sprintf ('select ?s ?p (bif:search_excerpt (bif:vector (%s), sql:rdf_find_str(?o))) ' ||
	    'where { ?s ?p ?o . %s filter (bif:contains (?o, ''%s'')) } limit %d', vec, cond, ft, maxrows);
	}
      else if ('default-graph-uri' = pname and length (pvalue))
        {
	  if (position (pvalue, dflt_graphs) <= 0)
	    dflt_graphs := vector_concat (dflt_graphs, vector (pvalue));
	}
      else if ('named-graph-uri' = pname and length (pvalue))
        {
	  if (position (pvalue, named_graphs) <= 0)
	    named_graphs := vector_concat (named_graphs, vector (pvalue));
	}
      else if ('using-graph-uri' = pname and length (pvalue))
        {
	  if (position (pvalue, using_graphs) <= 0)
	    using_graphs := vector_concat (using_graphs, vector (pvalue));
	}
      else if ('using-named-graph-uri' = pname and length (pvalue))
        {
	  if (position (pvalue, using_named_graphs) <= 0)
	    using_named_graphs := vector_concat (using_named_graphs, vector (pvalue));
	}
      else if ('maxrows' = pname)
        {
	  maxrows := cast (pvalue as integer);
	}
      else if ('should-sponge' = pname)
        {
          if (can_sponge)
            should_sponge := trim(pvalue);
	}
      else if ('format' = pname or 'output' = pname)
        {
	  format := pvalue;
	}
      else if ('timeout' = pname and length (pvalue))
        {
          declare t integer;
          t := atoi (pvalue);
          if (t is not null and t >= 1000)
            {
              if (hard_timeout >= 1000)
                timeout := __min (t, hard_timeout);
              else
                timeout := t;
            }
          client_supports_partial_res := 1;
	}
      else if ('ini' = pname)
        {
	  sp_ini := 1;
	}
      else if (query is null and 'query-uri' = pname and length (pvalue))
	{
	  if (virtuoso_ini_item_value ('SPARQL', 'ExternalQuerySource') = '1')
	    {
	      declare uri varchar;
	      declare hf, hdr, charset any;
	      uri := pvalue;
	      if (uri like 'http://%' and uri not like 'http://localdav.virt/%' and uri not like 'http://local.virt/dav/%')
		{
		  query := http_get (uri, hdr);
		  if (hdr[0] not like '% 200%')
		    signal ('22023', concat ('HTTP request failed: ', hdr[0], 'for URI ', uri));
		  charset := http_request_header (hdr, 'Content-Type', 'charset', '');
		  if (charset <> '')
		    {
		      query := charset_recode (query, charset, 'UTF-8');
		    }
		}
	      else
		{
		  query := DB.DBA.XML_URI_GET ('', pvalue);
	        }
	    }
	  else
	    {
	       DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
		    '403', 'Prohibited', query, '22023', 'The external query sources are prohibited.');
	       return;
	    }
	}
      else if ('xslt-uri' = pname and length (pvalue))
	{
	  if (virtuoso_ini_item_value ('SPARQL', 'ExternalXsltSource') = '1')
	    {
	      add_http_headers := 0;
	      http_xslt (pvalue);
	    }
	  else
	    {
	       DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
		    '403', 'Prohibited', query, '22023', 'The XSL-T transformation is prohibited');
	       return;
	    }
	}
      else if ('get-login' = pname)
	  get_user := pvalue;
      else if ('callback' = pname)
          jsonp_callback := pvalue;
      else if (pname[0] = '?'[0])
          dict_put (qry_params, subseq (pname, 1), pvalue);
      else if ('signal_void' = pname)
        signal_void := pvalue;
      else if ('signal_unconnected' = pname)
        signal_unconnected := pvalue;
      else if ('quiet_geo' = pname)
        quiet_geo := pvalue;
      else if ('debug' = pname)
        {
          if ('1' = pvalue)
            signal_void := signal_unconnected := pvalue;
        }
      else if ('log_debug_info' = pname)
        {
          log_debug_info := pvalue;
          -- dbg_obj_princ ('log_debug_info := ', pvalue);
        }
      else
        {
          -- dbg_obj_princ ('Unknown parameter ', pname, ' = ', pvalue);
          ;
        }
    }
  if (format <> '')
  {
    format := (
      case lower(format)
        when 'json' then 'application/sparql-results+json'
        when 'js' then 'application/javascript'
        when 'html' then 'text/html'
        when 'sparql' then 'application/sparql-results+xml'
        when 'xml' then 'application/sparql-results+xml'
        when 'rdf' then 'application/rdf+xml'
        when 'n3' then 'text/rdf+n3'
        when 'ttl' then 'text/turtle'
        when 'turtle' then 'text/turtle'
        when 'cxml' then 'text/cxml'
        when 'cxml+qrcode' then 'text/cxml+qrcode'
        when 'csv' then 'text/csv'
        else format
      end);
  }

  if (def_max > 0 and def_max < maxrows)
    maxrows := def_max;

  --if (0 = length (dflt_graphs) and length (ini_dflt_graph))
  --  dflt_graphs := vector (ini_dflt_graph);


  -- SOAP 1.2 operation begins
  if (http_meth = 'POST' and soap_ver > 0)
    {
       declare xt, dgs, ngs any;
       declare soap_ns, spt_ns, ns_decl varchar;
       soap_ns := DB.DBA.SPARQL_SOAP_NS (soap_ver);
       spt_ns := DB.DBA.SPARQL_PT_NS ();
       ns_decl := '[ xmlns:soap="'||soap_ns||'" xmlns:sp="'||spt_ns||'" ] ';
       content := http_body_read ();
       if (__debug_mode)
         dbg_printf ('content=[%s]', string_output_string (content));
       xt := xtree_doc (content);
       query := charset_recode (xpath_eval (ns_decl||'string (/soap:Envelope/soap:Body/sp:query-request/query)', xt), '_WIDE_', 'UTF-8');
       dgs := xpath_eval (ns_decl||'/soap:Envelope/soap:Body/sp:query-request/default-graph-uri', xt, 0);
       ngs := xpath_eval (ns_decl||'/soap:Envelope/soap:Body/sp:query-request/named-graph-uri', xt, 0);
       foreach (any frag in dgs) do
	 {
	   declare pvalue varchar;
	   pvalue := charset_recode (xpath_eval ('string(.)', frag), '_WIDE_', 'UTF-8');
	   if (position (pvalue, dflt_graphs) <= 0)
	     dflt_graphs := vector_concat (dflt_graphs, vector (pvalue));
	 }
       foreach (any frag in ngs) do
	 {
	   declare pvalue varchar;
	   pvalue := charset_recode (xpath_eval ('string(.)', frag), '_WIDE_', 'UTF-8');
	   if (position (pvalue, named_graphs) <= 0)
	     named_graphs := vector_concat (named_graphs, vector (pvalue));
	 }
       format := sprintf('application/soap+xml;%d', soap_ver);
    }
  if (format <> '')
    accept := format;
  else
    accept := DB.DBA.HTTP_RDF_GET_ACCEPT_BY_Q (http_request_header_full (lines, 'Accept', '*/*'));
  if (sp_ini)
    {
      DB.DBA.SPARQL_INI_PARAMS (metas, rset);
      goto write_results;
    }

  if (query is null)
    {
      if (strstr (content_type, 'application/xml') is not null)
        {
          DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
            '400', 'Bad Request',
	    query, '22023', 'XML notation of SPARQL queries is not supported' );
	  return;
	}
      DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
        '400', 'Bad Request',
        query, '22023', 'The request does not contain text of SPARQL query', format);
      return;
    }

  full_query := query;
  -- dbg_obj_princ ('dflt_graphs = ', dflt_graphs, ', named_graphs = ', named_graphs);
  --if (quiet_geo <> '')
  --  full_query := 'define sql:select-option "QUIETGEO"\n' || full_query;
  declare req_hosts varchar;
  declare req_hosts_split any;
  declare hctr integer;
  req_hosts := http_request_header (lines, 'Host', null, null);
  req_hosts := replace (req_hosts, ', ', ',');
  req_hosts_split := split_and_decode (req_hosts, 0, '\0\0,');
  for (hctr := length (req_hosts_split) - 1; hctr >= 0; hctr := hctr - 1)
    {
      for (select top 1 SH_GRAPH_URI, SH_DEFINES from DB.DBA.SYS_SPARQL_HOST
      where req_hosts_split [hctr] like SH_HOST) do
        {
          if (length (dflt_graphs) = 0 and length (SH_GRAPH_URI))
            dflt_graphs := vector (SH_GRAPH_URI);
          if (SH_DEFINES is not null)
            full_query := concat (SH_DEFINES, '\n', full_query);
          goto host_found;
        }
    }
host_found:

  foreach (varchar dg in dflt_graphs) do
    {
      full_query := concat ('define input:default-graph-uri <', dg, '>\n', full_query);
      http_header (http_header_get () || sprintf ('X-SPARQL-default-graph: %s\r\n', dg));
    }
  foreach (varchar ng in named_graphs) do
    {
      full_query := concat ('define input:named-graph-uri <', ng, '>\n', full_query);
      http_header (http_header_get () || sprintf ('X-SPARQL-named-graph: %s\r\n', ng));
    }
  foreach (varchar dg in using_graphs) do
    {
      full_query := concat ('define input:using-graph-uri <', dg, '>\n', full_query);
      http_header (http_header_get () || sprintf ('X-SPARQL-using-graph: %s\r\n', dg));
    }
  foreach (varchar ng in using_named_graphs) do
    {
      full_query := concat ('define input:using-named-graph-uri <', ng, '>\n', full_query);
      http_header (http_header_get () || sprintf ('X-SPARQL-using-named-graph: %s\r\n', ng));
    }
  if ((should_sponge = 'soft') or (should_sponge = 'replacing'))
    full_query := concat (sprintf('define get:soft "%s"\n',should_sponge), full_query);
  else if (should_sponge = 'grab-all')
    full_query := concat ('define input:grab-all "yes"\ndefine input:grab-depth 5\ndefine input:grab-limit 100\n', full_query);
  else if (should_sponge = 'grab-all-seealso')
    full_query := concat ('define input:grab-all "yes"\ndefine input:grab-depth 5\ndefine input:grab-limit 200\ndefine input:grab-seealso <http://www.w3.org/2000/01/rdf-schema#seeAlso>\ndefine input:grab-seealso <http://xmlns.com/foaf/0.1/seeAlso>\n', full_query);
  else if (should_sponge = 'grab-everything')
    full_query := concat ('define input:grab-all "yes"\ndefine input:grab-intermediate "yes"\ndefine input:grab-depth 5\ndefine input:grab-limit 500\ndefine input:grab-seealso <http://www.w3.org/2000/01/rdf-schema#seeAlso>\ndefine input:grab-seealso <http://xmlns.com/foaf/0.1/seeAlso>\n', full_query);
--  full_query := concat ('define output:valmode "LONG" ', full_query);
  if (signal_void <> '')
    full_query := concat ('define sql:signal-void-variables 1\n', full_query);
  --if (signal_unconnected <> '')
  --  full_query := concat ('define sql:signal-unconnected-variables 1\n', full_query);
  if (get_user <> '')
    full_query := concat ('define get:login "', get_user, '"\n', full_query);
  if (dict_size (qry_params) > 0)
    {
      declare pnames any;
      pnames := dict_list_keys (qry_params, 0);
      foreach (varchar pname in pnames) do
        {
          full_query := concat ('define sql:param "', pname, '"\n', full_query);
        }
      qry_params := DB.DBA.PARSE_SPARQL_WS_PARAMS (dict_to_vector (qry_params, 1));
    }
  else
    qry_params := vector ();
  if (save_mode is not null and save_mode <> 'display')
    client_supports_partial_res := 0; -- because result is not sent at all in this case

  if (format <> '')
    {
      full_query := '#output-format:' || format || '\n' || full_query;
    }
  if (not client_supports_partial_res) -- partial results do not work with chunked encoding
    {
    -- No need to choose accurately if there are no variants.
    -- Disabled due to empty results:
    --  if (strchr (accept, ' ') is null)
    --    {
    --      if (accept='application/sparql-results+xml')
    --        full_query := 'define output:format "HTTP+XML application/sparql-results+xml" ' || full_query;
    ----      else if (accept='application/rdf+xml')
    ----        full_query := 'define output:format "HTTP+RDF/XML application/rdf+xml" ' || full_query;
    --    }
    --  else
    -- No need to choose accurately if there is the best variant.
    -- Disabled due to empty results:
    --    {
          declare fmtxml, fmtttl varchar;
          if (strstr (accept, 'application/sparql-results+xml') is not null)
            fmtxml := '"HTTP+XML application/sparql-results+xml" ';
          if (strstr (accept, 'text/rdf+n3') is not null)
            fmtttl := '"HTTP+TTL text/rdf+n3" ';
          else if (strstr (accept, 'text/rdf+ttl') is not null)
            fmtttl := '"HTTP+TTL text/rdf+ttl" ';
          else if (strstr (accept, 'text/rdf+turtle') is not null)
            fmtttl := '"HTTP+TTL text/rdf+turtle" ';
          else if (strstr (accept, 'text/turtle') is not null)
            fmtttl := '"HTTP+TTL text/turtle" ';
          else if (strstr (accept, 'application/turtle') is not null)
            fmtttl := '"HTTP+TTL application/turtle" ';
          else if (strstr (accept, 'application/x-turtle') is not null)
            fmtttl := '"HTTP+TTL application/x-turtle" ';
          if (isstring (fmtttl))
            {
              if (isstring (fmtxml))
                full_query := 'define output:format ' || fmtxml || '\ndefine output:dict-format ' || fmtttl || '\n' || full_query;
              else
                full_query := 'define output:format ' || fmtttl || '\n' || full_query;
            }
    --    }
    ;
    }
  -- if odata asked we imply CBD
  if (accept = 'application/atom+xml' or accept = 'application/odata+json')
    {
      full_query := 'define sql:describe-mode "CBD"\n' || full_query;
    }

  state := '00000';
  metas := null;
  rset := null;
  if (__debug_mode)
    dbg_printf ('query=[%s]', full_query);

  declare sc_max int;
  declare sc decimal;
  sc_max := atoi (coalesce (virtuoso_ini_item_value ('SPARQL', 'MaxQueryCostEstimationTime'), '-1'));
  if (sc_max < 0)
    sc_max := atoi (coalesce (virtuoso_ini_item_value ('SPARQL', 'MaxExecutionTime'), '-1'));
  if (sc_max > 0)
    full_query := concat ('define sql:big-data-const 0\n', full_query);

  -- dbg_obj_princ ('accept = ', accept);
  -- dbg_obj_princ ('format = ', format);
  -- dbg_obj_princ ('full_query = ', full_query);
  -- dbg_obj_princ ('qry_params = ', qry_params);
  -- dbg_obj_princ ('save_mode = ', save_mode, ' save_dir = ', save_dir);

  signed_query_to_exec := concat ('sparql {\n', full_query, '\n}');

  if (sc_max > 0)
    {
      state := '00000';
      sc := exec_score (signed_query_to_exec, state, msg);
      if ((sc/1000) > sc_max)
        signal ('42000', sprintf ('The estimated execution time %d (sec) exceeds the limit of %d (sec).', sc/1000, sc_max));
    }


  if (explain_report <> '')
    {
      WS.WS.SPARQL_ENDPOINT_EXPLAIN_REPORT (full_query);
      return;
    }

  state := '00000';
  metas := null;
  rset := null;
  commit work;
  if (client_supports_partial_res and (timeout > 0))
    {
      set RESULT_TIMEOUT = timeout;
      -- dbg_obj_princ ('anytime timeout is set to', timeout);
      set TRANSACTION_TIMEOUT=timeout + 10000;
    }
  else if (hard_timeout >= 1000)
    {
      set TRANSACTION_TIMEOUT=hard_timeout;
    }
  connection_set ('DB.DBA.RDF_LOG_DEBUG_INFO', log_debug_info);
  set_user_id (user_id, 1);

again:
  state := '00000';
  start_time := msec_time();
  exec ( signed_query_to_exec, state, msg, qry_params, vector ('max_rows', maxrows, 'use_cache', 1), metas, rset);
  commit work;
  if (isvector (rset) and length (rset) = maxrows)
    http_header (http_header_get () || sprintf ('X-SPARQL-MaxRows: %d\r\n', maxrows));
  -- dbg_obj_princ ('exec metas=', metas, ', state=', state, ', msg=', msg);
  if (state = '00000')
    goto write_results;
  if (state = 'S1TAT')
    {
      exec_time := msec_time () - start_time;
      exec_db_activity := db_activity ();
      --reply := xmlelement ("facets", xmlelement ("sparql", qr), xmlelement ("time", msec_time () - start_time),
      --                 xmlelement ("complete", cplete),
      --                 xmlelement ("db-activity", db_activity ()), res[0][0]);
    }
  else if ((not http_is_flushed ()) and state = '40001' and deadl < 6)
    {
      declare dt int;
      rollback work;
      -- dbg_obj_princ ('deadlock and http is not flushed, deadlock counter ', deadl);
      deadl := deadl + 1;
      dt := ((rnd (5) + 1) / 10.0) * (2 * deadl);
      delay (dt);
      goto again;
    }
  else
    {
      declare state2, msg2 varchar;
      state2 := '00000';
      exec ('isnull (sparql_to_sql_text (''{ define sql:big-data-const 0 '' || ? || ''\\n}''))', state2, msg2, vector (full_query));
      if (state2 <> '00000')
        {
          declare unknown_service varchar;
          unknown_service := connection_get ('SPARQL_endpoint_to_load_service_metadata');
          if (__tag (unknown_service) in (__tag of varchar, __tag of UNAME))
            {
              if (isinteger (reported_unknown_services))
                reported_unknown_services := dict_new ();
              if (not dict_get (reported_unknown_services, unknown_service, 0))
                {
                  declare state3, msg3 varchar;
                  state3 := '00000';
                  exec ('sparql load service ?? data', state3, msg3, vector (unknown_service));
                  -- dbg_obj_princ ('exec state3=', state3, ', msg3=', msg3);
                  if (state3 <> '00000')
                    {
                      DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
                        '500', 'SPARQL Request Failed',
                        full_query, state3, msg3, format);
                      return;
                    }
                  dict_put (reported_unknown_services, unknown_service, 1);
                  connection_get ('SPARQL_endpoint_to_load_service_metadata', null);
                  commit work;
                  goto again;
                }
            }
          DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
            '400', 'Bad Request',
            full_query, state2, msg2, format);
          return;
        }
      DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
        '500', 'SPARQL Request Failed',
        full_query, state, msg, format);
      return;
    }

write_results:
  -- dbg_obj_princ ('writing results');
  if (save_mode is not null)
    {
      declare status any;
      if ((1 = length (metas[0])) and ('aggret-0' = metas[0][0][0]))
        {
          DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
            '500', 'SPARQL Request Failed',
            full_query, '00000', 'The result of the query can not be saved to a DAV resource', format);
          return;
        }
    }
  if ((1 <> length (metas[0])) or ('aggret-0' <> metas[0][0][0]))
    {
      declare status any;
      if (isinteger (msg))
        status := NULL;
      else
        status := vector (state, msg, exec_time, exec_db_activity);
      if (save_mode is not null)
        {
          if ((not isinteger (save_dir_id)) or not exists (select top 1 1 from WS.WS.SYS_DAV_COL where COL_ID = save_dir_id and COL_DET='DynaRes'))
            {
              DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
                '500', 'SPARQL Request Failed',
                full_query, '00000', sprintf ('To keep saved SPARQL results, the DAV directory "%.200s" should be of DAV extension type "DynaRes"', save_dir), format);
              return;
            }
          if (fname is not null)
            {
              if (strchr (fname, '/') is not null)
                {
                  DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
                    '500', 'SPARQL Request Failed',
                    full_query, '00000', sprintf ('The specified resource name "%.200s" contains illegal characters', fname), format);
                  return;
                }
            }
          ses := string_output ();
          add_http_headers := 0;
        }
      if (isstring (jsonp_callback))
        http (jsonp_callback || '(\n', ses);
      DB.DBA.SPARQL_RESULTS_WRITE (ses, metas, rset, accept,
        case when add_http_headers then 1 else 0 end + case log_debug_info when '' then 0 else 2 end,
        status);
      if (isstring (jsonp_callback))
        http (')', ses);
      if (save_mode is not null)
        {
          declare sparql_uid integer;
          declare refresh_sec, ttl_sec integer;
          declare full_uri varchar;
          sparql_uid := (SELECT COL_OWNER from WS.WS.SYS_DAV_COL where COL_ID = save_dir_id);
          if (fname is null)
            {
              if (save_mode = 'tmpstatic')
                fname := sprintf ('%.100s - SPARQL result - made by %.100s', cast (now() as varchar), user_id);
              else
                fname := sprintf ('%.100s - cached and renewable SPARQL result - made by %.100s', cast (now() as varchar), user_id);
            }
          refresh_sec := case (save_mode) when 'tmpstatic' then null else __max (600, coalesce (hard_timeout, 1000)/100) end;
          ttl_sec := 172800;
          full_uri := concat ('http://', registry_get ('URIQADefaultHost'), DAV_SEARCH_PATH (save_dir_id, 'C'), fname);
          "DynaRes_INSERT_RESOURCE" (
              detcol_id => save_dir_id,
              fname => fname,
              owner_uid => sparql_uid,
              refresh_seconds => refresh_sec,
              ttl_seconds => ttl_sec,
              mime => accept,
              exec_stmt => 'DB.DBA.SPARQL_REFRESH_DYNARES_RESULTS (?, ?, ?, ?, ?, ?, ?)',
              exec_params => vector (full_query, qry_params, maxrows, accept, user_id, hard_timeout, jsonp_callback),
              exec_uname => user_id,
              content => ses,
              overwrite => atoi (overwrite)
          );
          WS.WS.SPARQL_ENDPOINT_HTML_DOCTYPE();
          http ('<head>\n');
          WS.WS.SPARQL_ENDPOINT_HTML_HEAD('Virtuoso SPARQL Query Editor | Save to DAV');
          WS.WS.SPARQL_ENDPOINT_STYLE (1);
          http ('</head>\n');
          http ('<body>\n');
          http('<div class="container">\n');
          http ('    <div id="header">\n');
          http ('	<h1 id="title">Virtuoso SPARQL Query Editor</h1>\n');
          http ('    </div>\n\n');
          http ('<h3>Saved to DAV</h3>');
          http ('<p>The SPARQL result is successfully saved in DAV storage as <a href="');
          http_value (full_uri);
          http ('">');
          http_value (full_uri);
          http ('</a></p>');
          if (refresh_sec is not null)
          http (sprintf ('<p>The content of the linked resource will be re-calculated on demand, and the result will be cached for %d minutes.</p>', refresh_sec/60));
          if (ttl_sec is not null)
          http (sprintf ('<p>The link will stay valid for %d days. To preserve the referenced document for future use, copy it to some other location before expiration.</p>', ttl_sec/(60*60*24)));
          if (accept <> 'text/html')
          http (sprintf ('<p>The resource MIME type is "%s". This type will be reported to the browser when you click on the link.
          If the browser is unable to open the link itself it can prompt for action like launching an additional program.
          The program may let you edit the loaded resource, in this case save the changed version should be saved to a different place, so use "Save As" command, not plain "Save".</p>', accept));
          http('</div>\n');
          http ('</body></html>');
        }
    }
  else
    {
      if (save_mode is not null)
        {
          DB.DBA.SPARQL_PROTOCOL_ERROR_REPORT (path, params, lines,
            '500', 'SPARQL Request Failed',
            full_query, '00000', 'The result of the query can not be saved to a DAV resource', format);
          return;
        }
    }
}
;

registry_set ('/!sparql/', 'no_vsp_recompile')
;

create function WS.WS.SPARQL_ENDPOINT_QMV_RET_DESCR (in qmv IRI_ID, in fldname varchar)
{
  declare ans varchar;
  ans := (sparql define output:valmode "LONG" define input:storage "" select ?v from virtrdf: where
      { `iri(?:qmv)` virtrdf:qmvRange-rvrFixedValue ?v . } );
  if (ans is not null)
    return fldname || ' &lt;' || id_to_iri (ans) || '&gt;';
  ans := (sparql define output:valmode "LONG" define input:storage "" select GROUP_CONCAT (bif:concat ("&quot;", str(?sff), "&quot;"), ", ") from virtrdf: where
      { `iri(?:qmv)` virtrdf:qmvFormat/virtrdf:qmfValRange-rvrSprintffs ?sffs . ?sffs ?p ?sff . filter (isliteral(?sff)) } );
  if (length (ans))
    return fldname || 's named like "' || ans || '"';
--  ans := (sparql define output:valmode "LONG" define input:storage "" select str(?cs) from virtrdf: where
--      { `iri(?:qmv)` virtrdf:qmvFormat/virtrdf:qmfCustomString1 ?cs . filter (isliteral(?cs)) } );
--  if (ans is not null)
--    return fldname || 's of format "' || ans || '"';
  ans := (sparql define output:valmode "LONG" define input:storage "" select ?qmf from virtrdf: where
      { `iri(?:qmv)` virtrdf:qmvFormat ?qmf . filter (isiri(?qmf)) } );
  if (ans is not null)
    return 'various ' || fldname || 's named by format &lt;' || id_to_iri (ans) || '&gt;';
  return 'various ' || fldname || 's';
}
;

create procedure WS.WS.SPARQL_ENDPOINT_QM_OVERVIEW (in qm IRI_ID)
{
#pragma prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#>
#pragma prefix rdfdf: <http://www.openlinksw.com/virtrdf-data-formats#>
  declare needs_delim integer;
  http ('The quad map provides triples for ');
  needs_delim := 0;
  for (sparql define output:valmode "LONG" define input:storage "" select distinct ?fv from virtrdf: where
      { ?qm2 a virtrdf:QuadMap .
        filter (?qm2 = iri(?:qm))
          { select ?qm2 ?sub_qm from virtrdf: where { ?qm2 virtrdf:qmUserSubMaps [ ?p ?sub_qm ] . ?sub_qm a virtrdf:QuadMap . }
          } option ( transitive, t_in (?qm2), t_out (?sub_qm), t_min (0), t_distinct )
        ?sub_qm virtrdf:qmGraphRange-rvrFixedValue ?fv . filter (isiri(?fv))
      } ) do
    {
      if (needs_delim) http ('; '); else needs_delim := 1;
      http ('<nobr>graph &lt;' || id_to_iri ("fv") || '&gt;</nobr>');
    }
  for (select distinct WS.WS.SPARQL_ENDPOINT_QMV_RET_DESCR (t."qmv", 'graph') as descr from
    (sparql define output:valmode "LONG" define input:storage "" select distinct ?qmv from virtrdf: where
      { ?qm2 a virtrdf:QuadMap .
        filter (?qm2 = iri(?:qm))
          { select ?qm2 ?sub_qm from virtrdf: where { ?qm2 virtrdf:qmUserSubMaps [ ?p ?sub_qm ] . ?sub_qm a virtrdf:QuadMap . }
          } option ( transitive, t_in (?qm2), t_out (?sub_qm), t_min (0), t_distinct )
        ?sub_qm virtrdf:qmGraphMap ?qmv .
      } ) as t ) do
    {
      if (needs_delim) http ('; '); else needs_delim := 1;
      http ('<nobr>' || descr || '</nobr>');
    }
  if (not needs_delim) http ('various graphs');
  http ('.<br/>');
  http ('The data come from ');
  needs_delim := 0;
  for (sparql define input:storage "" select distinct ?tbl from virtrdf: where
      { ?qm2 a virtrdf:QuadMap .
        filter (?qm2 = iri(?:qm))
          { select ?qm2 ?sub_qm from virtrdf: where { ?qm2 virtrdf:qmUserSubMaps [ ?p ?sub_qm ] . ?sub_qm a virtrdf:QuadMap . }
          } option ( transitive, t_in (?qm2), t_out (?sub_qm), t_min (0), t_distinct )
        ?sub_qm virtrdf:qmGraphMap|virtrdf:qmSubjectMap|virtrdf:qmPredicateMap|virtrdf:qmObjectMap ?qmv .
        { ?qmv virtrdf:qmvTableName ?tbl } union { ?qmv virtrdf:qmvATables ?ats . ?ats ?p ?at . ?at virtrdf:qmvaTableName ?tbl . }
      } ) do
    {
      if (needs_delim) http (', '); else needs_delim := 1;
      if ("tbl" = 'sinv' and ('http://www.openlinksw.com/schemas/virtrdf#DefaultServiceMap' = id_to_iri ("qm")))
        http ('system procedure views that compose and send HTTP requests to remote SPARQL service endpoints and then parse answers');
      else
        http ('<nobr>' || "tbl" || '</nobr>');
    }
}
;


registry_set ('/!sparql/', 'no_vsp_recompile')
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_CRUD_BASE_EV_NEW_BLANK (inout g_iid IRI_ID, inout app_env any, inout res IRI_ID)
{
  res := min_bnode_iri_id ();
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_CRUD_BASE_EV_TRIPLE (
  inout g_iid IRI_ID, inout s_uri varchar, inout p_uri varchar,
  inout o_uri varchar,
  inout app_env any )
{
  signal ('22023', 'The graph URI is relative and can not be resolved using the submitted resource (base should be declared before data for the first triple)');
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_CRUD_BASE_EV_TRIPLE_L (
  inout g_iid IRI_ID, inout s_uri varchar, inout p_uri varchar,
  inout o_val any, inout o_type varchar, inout o_lang varchar,
  inout app_env any )
{
  signal ('22023', 'The graph URI is relative and can not be resolved using the submitted resource (base should be declared before data for the first triple)');
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_CRUD_BASE_EV_NEW_BASE (
  inout base_uri varchar,
  inout graph_uri varchar,
  inout app_env any )
{
  app_env[0] := DB.DBA.XML_URI_RESOLVE_LIKE_GET (base_uri, graph_uri);
  signal ('ok001', '');
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_CRUD_BASE_TTL (inout strg any, in graph_uri varchar, in flags integer := 255)
{
  declare app_env any;
  if (126 = __tag (strg))
    strg := cast (strg as varchar);
  app_env := vector (null);
  whenever sqlstate 'ok001' goto done;
  rdf_load_turtle (strg, '', graph_uri, flags,
    vector (
      '',
      'DB.DBA.SPARQL_CRUD_BASE_EV_NEW_BLANK',
      'DB.DBA.TTLP_EV_GET_IID',
      'DB.DBA.SPARQL_CRUD_BASE_EV_TRIPLE',
      'DB.DBA.SPARQL_CRUD_BASE_EV_TRIPLE_L',
      '',
      '',
      'DB.DBA.SPARQL_CRUD_BASE_EV_NEW_BASE' ),
    app_env);
done:
  return app_env[0];
}
;

--!AWK PUBLIC
create procedure DB.DBA.SPARQL_CRUD_BASE_RDFXML (in strg any, in graph_uri varchar)
{
  declare app_env any;
  app_env := vector (null);
  whenever sqlstate 'ok001' goto done;
  rdf_load_rdfxml (strg, 0,
    graph_uri,
    vector (
      '',
      'DB.DBA.SPARQL_CRUD_BASE_EV_NEW_BLANK',
      'DB.DBA.TTLP_EV_GET_IID',
      'DB.DBA.SPARQL_CRUD_BASE_EV_TRIPLE',
      'DB.DBA.SPARQL_CRUD_BASE_EV_TRIPLE_L',
      '',
      '',
      'DB.DBA.SPARQL_CRUD_BASE_EV_NEW_BASE' ),
    app_env );
done:
  return app_env[0];
}
;

create procedure WS.WS."/!sparql-graph-crud/" (inout path varchar, inout params any, inout lines any)
{
  declare user_id varchar;
  declare reqbegin varchar;
  declare graph_uri varchar;
  declare colonspace_pos integer;
  declare graph_uri_is_relative integer;
  {
  whenever sqlstate '*' goto err; /* see below */
  -- dbg_obj_princ ('===============');
  -- dbg_obj_princ ('===============');
  -- dbg_obj_princ ('===============');
  -- dbg_obj_princ ('WS.WS."/!sparql-graph-crud/" (', path, params, lines, ')');
  set http_charset='utf-8';
  user_id := connection_get ('SPARQLUserId', 'SPARQL');
  reqbegin := lines[0];
  graph_uri := trim(coalesce (get_keyword ('graph', params, null), get_keyword ('graph-uri', params, null), ''));
  if (isstring (get_keyword ('default', params)))
    {
      declare req_hosts varchar;
      declare req_hosts_split any;
      declare hctr integer;
      if (graph_uri <> '')
        signal ('22023', 'The request to SPARQL 1.1 Graph Store endpoint contains both "graph" and "default" params');
      req_hosts := http_request_header (lines, 'Host', null, null);
      req_hosts := replace (req_hosts, ', ', ',');
      req_hosts_split := split_and_decode (req_hosts, 0, '\0\0,');
      for (hctr := length (req_hosts_split) - 1; hctr >= 0; hctr := hctr - 1)
        {
          for (select top 1 SH_GRAPH_URI, SH_DEFINES from DB.DBA.SYS_SPARQL_HOST
          where req_hosts_split [hctr] like SH_HOST) do
            {
              if (length (SH_GRAPH_URI))
                {
                  graph_uri := SH_GRAPH_URI;
                  goto good_host_found;
                }
              goto bad_host_found;
            }
        }
bad_host_found:
      signal ('22023', 'The request to SPARQL 1.1 Graph Store endpoint contains "default" param but the endpoint is not configured to have default graph');
good_host_found:
      ;
    }
  if (graph_uri <> '')
    goto graph_processing;
  http_methods_set ('GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'PATCH');

  WS.WS.SPARQL_ENDPOINT_HTML_DOCTYPE();

  http('<head>\n');
  WS.WS.SPARQL_ENDPOINT_HTML_HEAD('Virtuoso SPARQL 1.1 Uniform RDF Graph Query Form');
  WS.WS.SPARQL_ENDPOINT_STYLE (1);
  http('</head>\n');

  http('<body>\n');
  http('<div class="container">\n');
  http('    <div id="header">\n');
  http('	<h1>Virtuoso SPARQL 1.1 Uniform RDF Graph Query Form</h1>\n');
  http('    </div>\n\n');
  http('    <div id="intro">\n');
  http('	<p>This page is designed to help you test support for <a href="http://www.w3.org/TR/sparql11-http-rdf-update">SPARQL 1.1 Graph Store HTTP Protocol</a> in OpenLink Virtuoso.</p>\n');
  http('    </div>\n\n');
  http('    <div id="main">\n');
  http('	<form action="" method="post" enctype="multipart/form-data">\n');
  http('	<fieldset>\n');
  http('		<label for="graph-uri">Graph URI</label>\n');
  http('		<br />\n');
  http('		<input type="text" name="graph-uri" id="graph-uri" ');
  http(sprintf ('value="%s" size="80"/>\n', coalesce ('')));
  http('		<br /><br />\n');
  http('		<label for="res-file">File to upload</label>\n');
  http('		<br />\n');
  http('		<input type="file" name="res-file" id="res-file"/>\n');
  http('		<br /><br />\n');
  http('		<input type="submit" value="Upload the resource"/>');
  http('	</fieldset>\n');
  http('	</form>\n');
  http('    </div>\n\n');
  WS.WS.SPARQL_ENDPOINT_FOOTER();
  http('</div>\n');
  http('</body>\n');
  http('</html>\n');
  return;
graph_processing:
  commit work;
  graph_uri_is_relative := neq (graph_uri, DB.DBA.XML_URI_RESOLVE_LIKE_GET ('zZz://example.com/', graph_uri));
  if (graph_uri_is_relative)
    {
      if (not (reqbegin like 'PUT%') and not (reqbegin like 'POST%'))
        signal ('22023', 'The graph URI <' || graph_uri || '> is relative and can be passed to SPARQL 1.1 Graph Store endpoint only in some PUT or POST requests');
    }
  if ((reqbegin like 'PUT%') or (reqbegin like 'POST%'))
    {
      declare res_file, res_content_type varchar;
      declare full_graph_uri varchar;
      declare graph_exists integer;
      set_user_id (user_id, 1);
      res_file := get_keyword ('res-file', params, '');
      -- dbg_obj_princ ('res_file/1=', cast (res_file as varchar));
      if (0 = length (res_file))
        res_file := get_keyword ('Content', params, '');
      -- dbg_obj_princ ('res_file/2=', string_output_string (res_file));
      if (0 = length (res_file))
        res_file := http_body_read();
      -- dbg_obj_princ ('res_file/3=', string_output_string (res_file));
      if (0 = length (res_file))
        res_file := http_body_read(1);
      -- dbg_obj_princ ('res_file/4=', string_output_string (res_file));
      res_content_type := DB.DBA.RDF_SPONGE_GUESS_CONTENT_TYPE (null, null, res_file);
      -- dbg_obj_princ ('res_content_type=', res_content_type);
      if (graph_uri_is_relative)
        {
          full_graph_uri := null;
          if (res_content_type in ('text/rdf+n3', 'text/turtle'))
            full_graph_uri := DB.DBA.SPARQL_CRUD_BASE_TTL (res_file, graph_uri, 255);
          else if (res_content_type = 'application/rdf+xml')
            full_graph_uri := DB.DBA.SPARQL_CRUD_BASE_RDFXML (res_file, graph_uri);
          else
            signal ('22023', 'The graph URI <' || graph_uri || '> is relative and can not be resolved using the submitted resource of unsupported type ' || coalesce (res_content_type, ''));
          if (full_graph_uri is null)
            signal ('22023', 'The graph URI <' || graph_uri || '> is relative and can not be resolved using the submitted resource (resource does not contain any base)');
        }
      else
        full_graph_uri := graph_uri;
      commit work;
      graph_exists := (sparql define input:storage "" ask where { graph `iri(?:full_graph_uri)` { ?s ?p ?o }});
      if (res_content_type in ('text/rdf+n3', 'text/turtle'))
        {
          if (reqbegin like 'PUT%')
            {
              sparql clear graph ?:full_graph_uri;
              commit work;
            }
          DB.DBA.TTLP (res_file, full_graph_uri, full_graph_uri);
        }
      else if (res_content_type = 'application/rdf+xml')
        {
          if (reqbegin like 'PUT%')
            {
              sparql clear graph ?:full_graph_uri;
              commit work;
            }
          DB.DBA.RDF_LOAD_RDFXML (res_file, full_graph_uri, full_graph_uri);
        }
      else if (res_content_type = 'text/microdata+html')
        {
          if (reqbegin like 'PUT%')
            {
              sparql clear graph ?:full_graph_uri;
              commit work;
            }
          DB.DBA.RDF_LOAD_XHTML_MICRODATA (res_file, full_graph_uri /* base */, full_graph_uri /* dest graph */);
        }
      else if (res_content_type = 'application/xhtml+xml')
        {
          if (reqbegin like 'PUT%')
            {
              sparql clear graph ?:full_graph_uri;
              commit work;
            }
          DB.DBA.RDF_LOAD_RDFA (res_file, full_graph_uri /* base */, full_graph_uri /* dest graph */);
        }
      else
        signal ('22023', 'The PUT request for graph <' || full_graph_uri || '> is rejected: the submitted resource is of unsupported type ' || coalesce (res_content_type, ''));
      if (graph_exists is null)
        http_request_status ('HTTP/1.1 201 Created');
      else if (length (res_file) <= 2)
        http_request_status ('HTTP/1.1 204 No Content');
      return;
    }
  if (reqbegin like 'DELETE%')
    {
      set_user_id (user_id, 1);
      if (not (exists (sparql define input:storage "" select (1) where { graph `iri(?:graph_uri)` { ?s ?p ?o }})))
        {
          http_request_status ('HTTP/1.1 404 Not Found');
          return;
        }
      sparql clear graph ?:graph_uri;
      commit work;
      return;
    }
  if (reqbegin like 'GET%')
    {
      if (not (exists (sparql define input:storage "" select (1) where { graph `iri(?:graph_uri)` { ?s ?p ?o }})))
        {
          http_request_status ('HTTP/1.1 404 Not Found');
          return;
        }
      connection_set ('SPARQL_crud_graph', graph_uri);
      WS.WS."/!sparql/" (path,
        vector_concat (
          vector ('query', 'define input:storage "" construct { ?s ?p ?o } where { graph `iri(bif:connection_get("SPARQL_crud_graph"))` { ?s ?p ?o }}'),
          params ), lines);
      return;
    }
  http_request_status ('HTTP/1.1 501 Method Not Implemented');
  return;
  }
err:
  colonspace_pos := strstr (__SQL_MESSAGE, ': ');
  if (colonspace_pos is not null and colonspace_pos < 50)
    {
      declare msg_begin varchar;
      msg_begin := "LEFT" (__SQL_MESSAGE, colonspace_pos+1);
      if (strstr (msg_begin, ':SECURITY:') is not null)
        {
          DB.DBA.HTTP_DEFAULT_ERROR_PAGE ('HTTP/1.1 403 Forbidden', 'SPARQL Graph Protocol request failed', null, __SQL_STATE, __SQL_MESSAGE);
          return;
        }
    }
  DB.DBA.HTTP_DEFAULT_ERROR_PAGE ('HTTP/1.1 500 Request Failed', 'SPARQL Graph Protocol request failed', null, __SQL_STATE, __SQL_MESSAGE);
  return;
}
;

registry_set ('/!sparql-graph-crud/', 'no_vsp_recompile')
;


create procedure DB.DBA.SPARQL_REFRESH_DYNARES_RESULTS (in full_query varchar, in qry_params any, in maxrows integer, in accept varchar, in user_id varchar, in hard_timeout integer, in jsonp_callback any)
{
  -- dbg_obj_princ ('DB.DBA.SPARQL_REFRESH_DYNARES_RESULTS (', full_query, qry_params, maxrows, accept, user_id, hard_timeout, ')');
  declare state, msg varchar;
  declare metas, rset any;
  declare RES any;
  declare ses any;
  result_names (RES);
  set_user_id (user_id, 1);
  if (hard_timeout >= 1000)
    set TRANSACTION_TIMEOUT = hard_timeout;
  set_user_id (user_id);
  state := '00000';
  exec ( concat ('sparql ', full_query), state, msg, qry_params, vector ('max_rows', maxrows, 'use_cache', 1), metas, rset);
  commit work;
  -- dbg_obj_princ ('exec metas=', metas, ', state=', state, ', msg=', msg);
  if (state <> '00000')
    signal (state, msg);
  ses := string_output ();
  if (isstring (jsonp_callback))
    http (jsonp_callback || '(\n', ses);
  DB.DBA.SPARQL_RESULTS_WRITE (ses, metas, rset, accept, 0, null);
  if (isstring (jsonp_callback))
    http (')', ses);
  result (ses);
}
;

-- SPARUL manipulation by remote resources.

--!AWK PUBLIC
create function DB.DBA.SPARQL_ROUTE_IF_DAV (in graph_iri varchar, in output_format_name varchar)
{
--                    0         1
--                    012345678901234567
  if (graph_iri like 'http://local.virt/DAV/%')
    return subseq (graph_iri, 17);
  return NULL;
}
;

create procedure DB.DBA.SPARQL_ROUTE_DICT_CONTENT_DAV (
  in graph_iri varchar,
  in opname varchar,
  in storage_name varchar,
  in output_storage_name varchar,
  in output_format_name varchar,
  in del_dict any,
  in ins_dict any,
  in env any,
  in uid varchar,
  in log_mode integer,
  in compose_report integer )
{
  declare split, in_mime, mime, perr, fake_content varchar;
  declare final_res, triples, out_ses, rc any;
   declare old_perms, pwd varchar;
  declare old_gid, old_uid any;
  declare dir any;
  split := DB.DBA.SPARQL_ROUTE_IF_DAV (graph_iri, output_format_name);
  -- uid := user;
  if ('dba' = uid)
    uid := 'dav';
  pwd := (select pwd_magic_calc (U_NAME, U_PASSWORD, 1) from SYS_USERS where U_NAME=uid);
  -- dbg_obj_princ ('SPARQL_ROUTE_DICT_CONTENT_DAV: uid=', uid, ', pwd=', pwd);
  if (split is not null)
    {
      dir := DAV_DIR_LIST (split, 0, uid, pwd);
      if (isinteger (dir) and (0 > dir))
        signal ('RDFXX', sprintf ('SPARUL %s can not get DAV directory info about "%.200s": %s', opname, split, DB.DBA.DAV_PERROR (dir)));
      if (1 = length (dir))
        {
          if ('c' = dir[0][1])
            signal ('RDFXX', sprintf ('SPARUL %s can not edit "%.200s": it is collection, not a resource', opname, split));
          old_perms := dir[0][5];
          old_gid := dir[0][6];
          old_uid := dir[0][7];
          in_mime := dir[0][9];
        }
      else
        signal ('RDFXX', sprintf ('SPARUL %s can not edit "%.200s": can not get directory listing with it', opname, split));
      fake_content := null;
      mime := DB.DBA.RDF_SPONGE_GUESS_CONTENT_TYPE (graph_iri, in_mime, fake_content);
      if ('application/rdf+xml' = mime)
        {
          if ((output_format_name is not null) and (output_format_name <> 'AUTO') and (output_format_name <> 'RDF/XML'))
            signal ('RDFXX', sprintf ('SPARUL can not update resource "%.200s" because its MIME type "%s" conflicts with directive output:format "%s"', graph_iri, coalesce (in_mime, mime), output_format_name));
        }
      else if (mime in ('text/rdf+n3', 'text/turtle'))
        {
          if ((output_format_name is not null) and (output_format_name <> 'AUTO') and (output_format_name <> 'TURTLE') and (output_format_name <> 'TTL'))
            signal ('RDFXX', sprintf ('SPARUL can not update resource "%.200s" because its MIME type "%s" conflicts with directive output:format "%s"', graph_iri, coalesce (in_mime, mime), output_format_name));
        }
      else
        signal ('RDFXX', sprintf ('SPARUL can not update resource "%.200s" of MIME type "%s" because only "application/rdf+xml", "text/rdf+n3" and  "text/turtle" are supported', graph_iri, coalesce (in_mime, mime)));
    }
  if ('INSERT' = opname)
    final_res := DB.DBA.SPARQL_INSERT_DICT_CONTENT (graph_iri, ins_dict, uid, log_mode, compose_report);
  else if ('DELETE' = opname)
    final_res := DB.DBA.SPARQL_DELETE_DICT_CONTENT (graph_iri, del_dict, uid, log_mode, compose_report);
  else if ('MODIFY' = opname)
    final_res := DB.DBA.SPARQL_MODIFY_BY_DICT_CONTENTS (graph_iri, del_dict, ins_dict, uid, log_mode, compose_report);
  if (split is not null)
    {
      out_ses := string_output();
      triples := (select VECTOR_AGG (vector ("s", "p", "o")) from
          (sparql define input:storage "" define output:valmode "LONG"
            select ?s ?p ?o where {
                graph `iri(?:graph_iri)` { ?s ?p ?o } }
            order by (str(?s)) (str(?p)) ) as sub );
      if ('application/rdf+xml' = mime)
        DB.DBA.RDF_TRIPLES_TO_RDF_XML_TEXT (triples, 1, out_ses);
      else if (('text/rdf+n3' = mime) or ('text/rdf+ttl' = mime) or ('text/rdf+turtle' = mime) or ('text/turtle' = mime) or ('text/n3' = mime) or ('text/x-nquads' = mime))
        DB.DBA.RDF_TRIPLES_TO_TTL (triples, out_ses);
      else if ('application/x-trig' = mime)
        DB.DBA.RDF_TRIPLES_TO_TRIG (triples, out_ses);
      else if ('text/plain' = mime or 'text/ntriples' = mime)
        DB.DBA.RDF_TRIPLES_TO_NT (triples, out_ses);
      else if (('application/json' = mime) or ('application/rdf+json' = mime) or ('application/x-rdf+json' = mime))
        DB.DBA.RDF_TRIPLES_TO_TALIS_JSON (triples, out_ses);
      else if ('application/x-json+ld' = mime)
        DB.DBA.RDF_TRIPLES_TO_JSON_LD (triples, out_ses);
      else if ('application/x-json+ld+ctx' = mime)
        DB.DBA.RDF_TRIPLES_TO_JSON_LD_CTX (triples, out_ses);
      else if ('application/ld+json' = mime)
        DB.DBA.RDF_TRIPLES_TO_JSON_LD_CTX (triples, out_ses);
      else if ('application/x-ld+json' = mime)
        DB.DBA.RDF_TRIPLES_TO_JSON_LD (triples, out_ses);
      else if ('application/xhtml+xml' = mime)
        DB.DBA.RDF_TRIPLES_TO_RDFA_XHTML (triples, out_ses);
      else if (('text/html' = mime) or ('text/microdata+html' = mime) or ('text/md+html' = mime))
        DB.DBA.RDF_TRIPLES_TO_HTML_MICRODATA (triples, out_ses);
      else if ('application/microdata+json' = mime)
        DB.DBA.RDF_TRIPLES_TO_JSON_MICRODATA (triples, out_ses);
      rc := DB.DBA.DAV_RES_UPLOAD (split, out_ses, mime, old_perms, old_uid, old_gid, uid, pwd);
      if (isinteger (rc) and rc < 0)
        signal ('RDFXX', sprintf ('Unable to change "%.200s" in DAV: %s', split, DB.DBA.DAV_PERROR (rc)));
    }
  if (not isinteger (final_res))
    return final_res;
}
;

-- WS handlers for .rq files (application/sparql-query)
create procedure
WS.WS.__http_handler_rq (in content any, in params any, in lines any, inout ipath_ostat any)
{
  return DB.DBA.http_rq_file_handler(content, params, lines, ipath_ostat);
}
;

create procedure
WS.WS.__http_handler_head_rq (in content any, in params any, in lines any, inout ipath_ostat any)
{
  return DB.DBA.http_rq_file_handler(content, params, lines, ipath_ostat);
}
;

create procedure
DB.DBA.http_rq_file_handler (in content any, in params any, in lines any, inout ipath_ostat any)
{
  declare accept varchar;
  declare _format varchar;

  accept := http_request_header (lines, 'Accept', null, '');

  _format := get_keyword('format', params, '');
  if (_format <> '')
    {
      _format := (
      case lower(_format)
      when 'json' then 'application/sparql-results+json'
      when 'js' then 'application/javascript'
      when 'html' then 'text/html'
      when 'spreadsheet' then 'application/vnd.ms-excel'
      when 'sparql' then 'application/sparql-results+xml'
      when 'xml' then 'application/sparql-results+xml'
      when 'rdf' then 'application/rdf+xml'
      when 'n3' then 'text/rdf+n3'
      when 'ttl' then 'text/turtle'
      when 'turtle' then 'text/turtle'
      when 'cxml' then 'text/cxml'
      when 'cxml+qrcode' then 'text/cxml+qrcode'
      when 'csv' then 'text/csv'
      else _format
      end);
    }

  if (_format <> '' or
      strcasestr (accept, 'application/sparql-results+json') is not null or
      strcasestr (accept, 'application/json') is not null or
      strcasestr (accept, 'application/sparql-results+xml') is not null or
      strcasestr (accept, 'text/rdf+n3') is not null or
      strcasestr (accept, 'text/rdf+ttl') is not null or
      strcasestr (accept, 'text/rdf+turtle') is not null or
      strcasestr (accept, 'text/turtle') is not null or
      strcasestr (accept, 'application/x-nquads') is not null or
      strcasestr (accept, 'application/x-trig') is not null or
      strcasestr (accept, 'application/rdf+xml') is not null or
      strcasestr (accept, 'application/javascript') is not null or
      strcasestr (accept, 'application/soap+xml') is not null or
      strcasestr (accept, 'application/rdf+turtle') is not null or
      strcasestr (accept, 'text/cxml') is not null or
      strcasestr (accept, 'text/cxml+qrcode') is not null or
      strcasestr (accept, 'text/csv') is not null or
      strcasestr (accept, 'application/x-nice-turtle') is not null or
      strcasestr (accept, 'text/x-html-script-ld+json') is not null or
      strcasestr (accept, 'text/x-html-script-turtle') is not null or
      strcasestr (accept, 'text/x-html-nice-turtle') is not null
     )
    {
      http_request_status ('HTTP/1.1 303 See Other');
      http_header (sprintf('Location: /sparql?query=%U&format=%U\r\n', content, accept));
      return '';
    }
  if (strcasestr (accept, 'application/sparql-query') is not null)
     http_header ('Content-Type: application/sparql-query\r\n');
  else
     http_header ('Content-Type: text/plain\r\n');
  http (content);
  return '';
}
;

create procedure DB.DBA.SPARQL_SD_TRIPLE (inout sd any, in s varchar, in p varchar, in o varchar)
{
  if (starts_with (s, '!')) s := __xml_nsexpand_iristr (subseq (s, 1)); else s := __bft (s, 1);
  if (starts_with (p, '!')) p := __xml_nsexpand_iristr (subseq (p, 1)); else p := __bft (p, 1);
  if (starts_with (o, '!')) o := __xml_nsexpand_iristr (subseq (o, 1)); else o := __bft (o, 1);
  vectorbld_acc (sd, vector (s, p, o));
}
;

create procedure DB.DBA.SPARQL_SD_TRIPLE_L (inout sd any, in s varchar, in p varchar, in o any)
{
  if (starts_with (s, '!')) s := __xml_nsexpand_iristr (subseq (s, 1)); else s := __bft (s, 1);
  if (starts_with (p, '!')) p := __xml_nsexpand_iristr (subseq (p, 1)); else p := __bft (p, 1);
  vectorbld_acc (sd, vector (s, p, o));
}
;

create procedure DB.DBA.SPARQL_SD_COMPOSE (inout sd any, in host varchar, in complete integer)
{
  declare service_iri varchar;
  service_iri := 'http://' || host || '/sparql-sd';
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!rdf:type', '!sd:Service');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:endpoint', 'http://' || host || '/sparql');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:endpoint', 'http://' || host || '/sparql-auth');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!virtrdf:graph-crud-endpoint', 'http://' || host || '/sparql-graph-crud');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!virtrdf:graph-crud-endpoint', 'http://' || host || '/sparql-graph-crud-auth');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:feature', '!sd:UnionDefaultGraph');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:feature', '!sd:RequiresDataset');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:feature', '!sd:EmptyGraphs');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:feature', '!sd:BasicFederatedQuery');
-- Results:
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/N3');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/N-triples');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/RDFa');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/RDF_XML');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/SPARQL_Results_XML');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/SPARQL_Results_JSON');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/SPARQL_Results_CSV');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', 'http://www.w3.org/ns/formats/Turtle');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_SPARQL_Results_HTML');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_SPARQL_Results_Spreadsheet');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_SPARQL_Results_Javascript');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_SPARQL_Results_CXML');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_SPARQL_Results_CXML_QR');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_RDF_JSON');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_XHTML_RDFa');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_ATOM_XML');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_ODATA_JSON');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_HTML_list');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_HTML_table');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_HTML_Microdata');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_Microdata_JSON');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_CSV');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_CXML');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Triples_CXML_QR');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:resultFormat', '!virtrdf:FileFormat_Quads_TriG');
-- Inputs:
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/N3');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/N-triples');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/RDFa');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/RDF_XML');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/SPARQL_Results_XML');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/SPARQL_Results_JSON');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/SPARQL_Results_CSV');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', 'http://www.w3.org/ns/formats/Turtle');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_SPARQL_Results_HTML');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_SPARQL_Results_Spreadsheet');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_SPARQL_Results_Javascript');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_SPARQL_Results_CXML');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_SPARQL_Results_CXML_QR');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_RDF_JSON');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_XHTML_RDFa');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_ATOM_XML');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_ODATA_JSON');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_HTML_list');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_HTML_table');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_HTML_Microdata');
  -- DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_Microdata_JSON');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_CSV');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_CXML');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Triples_CXML_QR');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:inputFormat', '!virtrdf:FileFormat_Quads_TriG');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:supportedLanguage', '!sd:SPARQL10Query');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:supportedLanguage', '!sd:SPARQL11Query');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:supportedLanguage', '!sd:SPARQL11Update');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_QUAD_MAP');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_OPTION');
--  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_BREAKUP');
--  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_PKSELFJOIN');
--  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_RVR');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_IN');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_LIKE');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_GLOBALS');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_BI');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_VIRTSPECIFIC');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_SERVICE');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_TRANSIT');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageExtension', '!virtrdf:SSG_SD_SPARQL11_DRAFT');
-- If some future standard features will not be supproted, there will be something like this:
--  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:languageException', '!virtrdf:SSG_SD_NO_SPARQL99_FOO');
  DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:propertyFeature', '!bif:contains');
  if (complete)
    { -- List of extension functions and aggregates --- TBD!
      DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:extensionFunction', '!bif:abs');
      DB.DBA.SPARQL_SD_TRIPLE (sd, service_iri, '!sd:extensionAggregate', '!sql:STDDEV');
    }
}
;

create procedure WS.WS."/!sparql-sd/" (inout path varchar, inout params any, inout lines any)
{
  declare sd, ses any;
  declare service_iri varchar;
  declare host, accept, formatter varchar;
  host := http_request_header (lines, 'Host', null, '');
  accept := http_request_header (lines, 'Accept', null, '');
  -- dbg_obj_princ ('WS.WS."/!sparql-sd/" (', path, params, lines, ')');
  if ((2 < length (params)) or (params[0] <> 'Content'))
    {
      WS.WS."/!sparql/" (path, params, lines);
      return;
    }
  vectorbld_init (sd);
  if (host is not null and host <> '')
    DB.DBA.SPARQL_SD_COMPOSE (sd, host, 1);
  if (isstring (registry_get ('URIQADefaultHost')))
    DB.DBA.SPARQL_SD_COMPOSE (sd, registry_get ('URIQADefaultHost'), 1);
  vectorbld_final (sd);
  ses := null;
  if (strstr (accept, 'text/rdf+n3') is not null)
    { http_header ('Content-Type: text/rdf+n3; charset=UTF-8\r\n');		DB.DBA.RDF_TRIPLES_TO_NT (sd, ses);	}
  else if (strstr (accept, 'text/turtle') is not null)
    { http_header ('Content-Type: text/turtle; charset=UTF-8\r\n');		DB.DBA.RDF_TRIPLES_TO_TTL (sd, ses);	}
  else if (strstr (accept, 'text/rdf+ttl') is not null)
    { http_header ('Content-Type: text/rdf+ttl; charset=UTF-8\r\n');		DB.DBA.RDF_TRIPLES_TO_TTL (sd, ses);	}
  else if (strstr (accept, 'text/rdf+turtle') is not null)
    { http_header ('Content-Type: text/rdf+turtle; charset=UTF-8\r\n');		DB.DBA.RDF_TRIPLES_TO_TTL (sd, ses);	}
  else if (strstr (accept, 'application/turtle') is not null)
    { http_header ('Content-Type: application/turtle; charset=UTF-8\r\n');	DB.DBA.RDF_TRIPLES_TO_TTL (sd, ses);	}
  else if (strstr (accept, 'application/turtle') is not null)
    { http_header ('Content-Type: application/x-turtle; charset=UTF-8\r\n');	DB.DBA.RDF_TRIPLES_TO_TTL (sd, ses);	}
  else
    { http_header ('Content-Type: text/turtle; charset=UTF-8\r\n');		DB.DBA.RDF_TRIPLES_TO_TTL (sd, ses);	}
}
;

registry_set ('/!sparql-sd/', 'no_vsp_recompile')
;

create procedure DB.DBA.RDF_GRANT_SPARQL_IO ()
{
  declare state, msg varchar;
  declare cmds any;
  cmds := vector (
    'grant execute on DB.DBA.SPARQL_REXEC to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_REXEC_TO_ARRAY to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_REXEC_WITH_META to SPARQL_SELECT',
    'grant execute on WS.WS."/!sparql/" to "SPARQL"',
    'grant execute on WS.WS."/!sparql-graph-crud/" to "SPARQL"',
    'grant execute on WS.WS."/!sparql-sd/" to "SPARQL"',
    'grant execute on DB.DBA.SPARQL_REFRESH_DYNARES_RESULTS to "SPARQL"',
    'grant execute on DB.DBA.SPARQL_ROUTE_DICT_CONTENT_DAV to SPARQL_UPDATE',
    'grant execute on DB.DBA.SPARQL_SD_PROBE to SPARQL_SPONGE',
    'grant execute on DB.DBA.SPARQL_SD_PROBE to SPARQL_LOAD_SERVICE_DATA',
    'grant execute on DB.DBA.SPARQL_SINV_IMP to SPARQL_SPONGE',
    'grant select on DB.DBA.SPARQL_SINV_2 to SPARQL_SPONGE',
    'grant execute on DB.DBA.SPARQL_RESULTS_XML_WRITE_HEAD to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_XML_WRITE_RES to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_XML_WRITE_ROW to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_NS to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_HEAD to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_RES to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_RDFXML_WRITE_ROW to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_TTL_WRITE_NS to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_TTL_WRITE_HEAD to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_TTL_WRITE_RES to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_NT_WRITE_NS to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_NT_WRITE_HEAD to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_NT_WRITE_RES to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_JAVASCRIPT_HTML_WRITE to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_JSON_WRITE_BINDING to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_JSON_WRITE to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_CSV_WRITE to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_TSV_WRITE to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_HTML_TR_WRITE to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_HTML_NICE_TTL_WRITE to SPARQL_SELECT',
    'grant execute on DB.DBA.SPARQL_RESULTS_WRITE to SPARQL_SELECT' );
  foreach (varchar cmd in cmds) do
    {
      exec (cmd, state, msg);
    }
}
;

--!AFTER __PROCEDURE__ DB.DBA.USER_CREATE !
DB.DBA.RDF_GRANT_SPARQL_IO ()
;
