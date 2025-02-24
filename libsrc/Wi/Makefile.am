#
#  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
#  project.
#
#  Copyright (C) 1998-2021 OpenLink Software
#
#  This project is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation; only version 2 of the License, dated June 1991.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
#

if WITH_IODBC
    IODBC_LIBS = libwi_odbc.la
endif

if WITH_LDAP
    LDAP_BIF=bif_ldapcli.c
endif

if WITH_KERBEROS
    KRB_BIF=bif_kerberoscli.c
endif

if WITH_IMSG
    IMSG_BIF= bif_pop3.c bif_imap.c bif_nntp.c
endif

if WITH_PLDEBUG
    PLDEBUG_FILES	= pldebug.c
    PLDEBUG_CLI_FILES	= pldbgcli.c
endif


GEN=$(SHELL) ${top_srcdir}/bin/generate


noinst_LTLIBRARIES = libwi.la libwic.la # $(IODBC_LIBS)
noinst_HEADERS = \
	2pc_client.h 2pc.h arith.h bif_text.h bif_xper.h blobio.h CLI.h \
	crsr.h date.h datesupp.h eqlcomp.h hosting.h http_client.h http.h \
	iodbcinst.h ksrvext.h ksrvextphp.h lisprdr.h list2.h log.h ltrx.h \
	map_schema.h msdtc.h mts_client.h mts_com.h mts.h multibyte.h \
	numeric.h odbcinc.h pldebug.h rdfinf.h rdf_core.h recovery.h remote.h \
	rendezvous.h repl.h replsr.h schspace.h security.h shuric.h \
	soap.h sparql2sql.h sparql.h sparql_p.h sql3.h sqlbif.h sqlcmps.h \
	sqlcomp.h sqlcstate.h sqlfn.h sqlintrp.h sqlnode.h sqlocr.h sqlofn.h \
	sqlo.h sqloinv.h sqlopcod.h sqlparext.h sqlpar.h sqlpfn.h sqlrcomp.h \
	sqltype_c.h sqltype.h sqlver.h sqlwords.h srvmultibyte.h srvstat.h \
	statuslog.h strlike.h subseq.h text.h turtle_p.h uuencode_impl.h \
	virtext.h virtpwd.h widd.h widisk.h widv.h wifn.h wi.h wirpce.h \
	wiservic.h wi_xid.h xmlenc_algos.h xmlenc.h xmlenc_test.h xmlgen.h \
	xml.h xmlnode.h xmlres.h xmltree.h xpath.h xpathp.h xpathp_impl.h \
	xpf.h xqf.h xslt_impl.h aqueue.h rdf_mapping_jso.h bitmap.h jso.h \
	json_p.h bif_audio_tags.h shcompo.h cluster.h extent.h uname_const_decl.h \
	col.h simd.h vec.h mhash.h qncache.h sparqlwords.h clq.h geo.h monitor.h



generated_code = \
	git_head.c \
	json_l.c \
	json_p.c \
	json_p.h \
	rdf_mapping_jso.c \
	rdf_mapping_jso.h \
	rdf_mapping_jso.ttl \
	rdf_mapping_jso.ttl-sample \
	nquad_p.c \
	nquad_p.h \
	scn3.c \
	scn3split.c \
	sparql_l.c \
	sparql_p.c \
	sparql_p.h \
	sparqlwords.h \
	sql3.c \
	sql_code.c \
	sql_code_1.c \
	sql_code_2pc.c \
	sql_code_adm.c \
	sql_code_auto.c \
	sql_code_cache.c \
	sql_code_dav.c \
	sql_code_dbp.c \
	sql_code_ddk.c \
	sql_code_imsg.c \
	sql_code_pldbg.c  \
	sql_code_repl.c \
	sql_code_sparql.c \
	sql_code_sys.c \
	sql_code_uddi.c \
	sql_code_vad.c \
	sql_code_vdb.c \
	sql_code_ws.c \
	sqlwords.h \
	sparqlwords.h \
	turtle_l.c \
	turtle_p.c \
	turtle_p.h \
	xpathp.c \
	xpathp.h \
	xpscn.c

BUILT_SOURCES = $(generated_code)
CLEANFILES = \
	sparql_p.output sql3.output turtle_p.output xpathp.output


C_FILES_SPARQL	= \
	jso.c \
	nquad_p.c \
	nquad_p.h \
	rdf_core.c \
	rdf_mapping_jso.c \
	rdfbox.c \
	rdfinf.c \
	rdfld.c \
	rdfxml_parser.c \
	sparql2sql.c \
	sparql2sqltext.c \
	sparql_core.c \
	sparql_l.c \
	sparql_p.c \
	sparql_qm.c \
	sparql_rdb2rdf.c \
	sparql_sff.c \
	sparql_tree.c \
	sparqld.c \
	sparul2sql.c \
	sql_code_sparql.c \
	turtle_l.c \
	turtle_p.c


libwi_la_SOURCES = \
	aqueue.c \
	arith.c \
	auxfiles.c \
	bif_audio.c \
	bif_crypto.c \
	bif_diff.c \
	bif_intl.c \
	bif_json.c \
	bif_regexp.c \
	bif_search_excerpt.c \
	bif_uuencode.c \
	bitmap.c \
	blob.c \
	blobio.c \
	ceins.c \
	cetop.c \
	chash.c \
	clcli.c \
	cldaq.c \
	clop.c \
	cldfg.c \
	cldt.c \
	clnode.c \
	clrdf.c \
	clserial.c \
	clsql.c \
	clsrv.c \
	cltrx.c \
	clvec.c \
	col.c \
	colin.c \
	colins.c \
	collock.c \
	cedel.c \
	colsearch.c \
	datesupp.c \
	ddlrun.c \
	disk.c \
	dks_esc.c \
	eqlcomp.c \
	extent.c \
	gate.c \
	git_head.c \
	hash.c \
	hosting.c \
	http.c \
	insert.c \
	inxop.c \
	json_l.c \
	json_p.c \
	lisprdr.c \
	lock.c \
	monitor.c \
	log.c \
	map_schema.c \
	meta.c \
	mtwrite.c \
	multibyte.c \
	neodisk.c \
	numeric.c \
	obackup.c \
	page.c \
	plugin_loader.c \
	read.c \
	recovery.c \
	regist.c \
	rendezvous.c \
	rltrx.c \
	row.c \
	schspace.c \
	scn3.c \
	search.c \
	search_in.c \
	security.c \
	shcompo.c \
	sort.c \
	space.c \
	sql3.c \
	sql_code.c \
	sql_code_1.c \
	sql_code_2pc.c \
	sql_code_adm.c \
	sql_code_auto.c \
	sql_code_cache.c \
	sql_code_dav.c \
	sql_code_dbp.c \
	sql_code_ddk.c \
	sql_code_imsg.c \
	sql_code_pldbg.c  \
	sql_code_repl.c \
	sql_code_sparql.c \
	sql_code_sys.c \
	sql_code_uddi.c \
	sql_code_vad.c \
	sql_code_vdb.c \
	sql_code_ws.c \
	sqlbif.c \
	sqlbif2.c \
	sqlcomp.c \
	sqlcomp2.c \
	sqlcost.c \
	sqlcr.c \
	sqldf.c \
	sqlexp.c \
	sqlgen.c \
	sqlhash.c \
	sqlintrp.c \
	sqlinx.c \
	sqljp.c \
	sqlo.c \
	sqloby.c \
	sqlocr.c \
	sqloinv.c \
	sqloinx.c \
	sqloprt.c \
	sqlorder.c \
	sqlovdb.c \
	sqlpfn.c \
	sqlprocc.c \
	sqlprt.c \
	sqlrun.c \
	sqlsrv.c \
	sqlstmts.c \
	sqltrig.c \
	sqltype.c \
	sqlvec.c \
	sqlver.c \
	sqlview.c \
	sqlvnode.c \
	sqlvrun.c \
	srvcr.c \
	srvmultibyte.c \
	srvstat.c \
	string.c \
	trans.c \
	update.c \
	uuencode.c \
	vec.c \
	vechash.c \
	vecins.c \
	vecrdf.c \
	vecsearch.c \
	wirpc.c \
	wiservic.c \
	xpathp.c \
	xpscn.c \
	$(C_FILES_SPARQL)

libwi_odbc_la_SOURCES = \
	aqueue.c \
	arith.c \
	auxfiles.c \
	bif_audio.c \
	bif_crypto.c \
	bif_diff.c \
	bif_intl.c \
	bif_json.c \
	bif_regexp.c \
	bif_search_excerpt.c \
	bif_uuencode.c \
	bitmap.c \
	blob.c \
	blobio.c \
	ceins.c \
	cetop.c \
	chash.c \
	clcli.c \
	cldaq.c \
	clop.c \
	cldfg.c \
	cldt.c \
	clnode.c \
	clrdf.c \
	clserial.c \
	clsql.c \
	clsrv.c \
	cltrx.c \
	clvec.c \
	col.c \
	colin.c \
	colins.c \
	collock.c \
	cedel.c \
	colsearch.c \
	datesupp.c \
	ddlrun.c \
	disk.c \
	dks_esc.c \
	eqlcomp.c \
	extent.c \
	gate.c \
	git_head.c \
	hash.c \
	hosting.c \
	http.c \
	insert.c \
	inxop.c \
	json_l.c \
	json_p.c \
	lisprdr.c \
	lock.c \
	monitor.c \
	log.c \
	map_schema.c \
	meta.c \
	mtwrite.c \
	multibyte.c \
	neodisk.c \
	numeric.c \
	obackup.c \
	page.c \
	plugin_loader.c \
	read.c \
	recovery.c \
	regist.c \
	rendezvous.c \
	rltrx.c \
	row.c \
	schspace.c \
	scn3.c \
	search.c \
	search_in.c \
	security.c \
	shcompo.c \
	sort.c \
	space.c \
	sql3.c \
	sql_code.c \
	sql_code_1.c \
	sql_code_2pc.c \
	sql_code_adm.c \
	sql_code_auto.c \
	sql_code_cache.c \
	sql_code_dav.c \
	sql_code_dbp.c \
	sql_code_ddk.c \
	sql_code_imsg.c \
	sql_code_pldbg.c  \
	sql_code_repl.c \
	sql_code_sparql.c \
	sql_code_sys.c \
	sql_code_uddi.c \
	sql_code_vad.c \
	sql_code_vdb.c \
	sql_code_ws.c \
	sqlbif.c \
	sqlbif2.c \
	sqlcomp.c \
	sqlcomp2.c \
	sqlcost.c \
	sqlcr.c \
	sqldf.c \
	sqlexp.c \
	sqlgen.c \
	sqlhash.c \
	sqlintrp.c \
	sqlinx.c \
	sqljp.c \
	sqlo.c \
	sqloby.c \
	sqlocr.c \
	sqloinv.c \
	sqloinx.c \
	sqloprt.c \
	sqlorder.c \
	sqlovdb.c \
	sqlpfn.c \
	sqlprocc.c \
	sqlprt.c \
	sqlrun.c \
	sqlsrv.c \
	sqlstmts.c \
	sqltrig.c \
	sqltype.c \
	sqlvec.c \
	sqlver.c \
	sqlview.c \
	sqlvnode.c \
	sqlvrun.c \
	srvcr.c \
	srvmultibyte.c \
	srvstat.c \
	string.c \
	trans.c \
	update.c \
	uuencode.c \
	vec.c \
	vechash.c \
	vecins.c \
	vecrdf.c \
	vecsearch.c \
	wirpc.c \
	wiservic.c \
	xpathp.c \
	xpscn.c \
	$(C_FILES_SPARQL)

libwi_la_SOURCES += \
	$(PLDEBUG_FILES)

libwi_odbc_la_SOURCES += \
	$(PLDEBUG_FILES)

#BIF_FILES
libwi_la_SOURCES += \
	bif_date.c \
	bif_dav.c \
	bif_explain.c \
	bif_file.c \
	bif_geo.c \
	bif_phrasematch.c \
	bif_smtp.c \
	bif_soap.c \
	bif_text.c \
	bif_tidy.c \
	geo.c \
	geo_de9im.c \
	geo_shapes.c \
	http_client.c \
	qncache.c \
	shuric.c \
	subseq.c \
	text.c \
	uname_const_decl.c \
	xmlenc-dec.c \
	xmlenc.c \
	xmlenc_algos.c \
	xmllazy.c \
	xmlschema.c \
	xmlsearch.c \
	xmlsql.c \
	xmltree.c \
	xpath.c \
	xpf.c \
	xqf.c \
	xslt.c \
	xslt_fmt.c \
	xslt_opt.c \
	$(LDAP_BIF) \
	$(KRB_BIF) \
	$(IMSG_BIF)

libwi_odbc_la_SOURCES += \
	bif_date.c \
	bif_dav.c \
	bif_explain.c \
	bif_file.c \
	bif_geo.c \
	bif_phrasematch.c \
	bif_smtp.c \
	bif_soap.c \
	bif_text.c \
	bif_tidy.c \
 	geo.c \
	geo_de9im.c \
	geo_shapes.c \
	http_client.c \
	qncache.c \
	shuric.c \
	subseq.c \
	text.c \
	uname_const_decl.c \
	xmlenc-dec.c \
	xmlenc.c \
	xmlenc_algos.c \
	xmllazy.c \
	xmlschema.c \
	xmlsearch.c \
	xmlsql.c \
	xmltree.c \
	xpath.c \
	xpathp.c \
	xpf.c \
	xqf.c \
	xslt.c \
	xslt_fmt.c \
	xslt_opt.c \
	$(LDAP_BIF) \
	$(KRB_BIF) \
	$(IMSG_BIF)

#BIF_XPER
libwi_la_SOURCES += \
	bif_xper.c

libwi_odbc_la_SOURCES += \
	bif_xper.c

libwi_base_la_cflags  = @VIRT_AM_CFLAGS@
libwi_base_la_cflags  += -I$(top_srcdir)/libsrc
libwi_base_la_cflags  += -I$(top_srcdir)/libsrc/Dk
libwi_base_la_cflags  += @ZLIB_INC@
libwi_base_la_cflags  += -I$(srcdir)
libwi_base_la_cflags  += -I$(top_srcdir)/libsrc/langfunc
libwi_base_la_cflags  += -I$(top_srcdir)/libsrc/plugin
libwi_base_la_cflags  += -I$(top_srcdir)/libsrc/Tidy
libwi_base_la_cflags  += -I$(top_srcdir)/libsrc/Xml.new
libwi_base_la_cflags  += -I$(top_srcdir)/libsrc/odbcsdk/include
libwi_base_la_cflags  += -DVAD
libwi_base_la_cflags  += -DDBP
libwi_base_la_cflags  += -DBIF_XPER -DOPSYS=\"@OPSYS@\" -DHOST=\"@host@\"
libwi_base_la_ldlags  = -static

#KUBL_UNIV_FILES
libwi_la_SOURCES += \
	2pc.c \
	bif_repl.c \
	bif_xml.c \
	odbccat.c \
	sqlrbuf.c \
	sqlrcomp.c \
	sqlrrun.c \
	wi_xid.c \
	$(libwi_base_la_sources)

libwi_la_CFLAGS  = $(libwi_base_la_cflags)
libwi_la_LDLAGS  = -static

#KUBL_UNIV_FILES_ODBC
libwi_odbc_la_SOURCES += \
	2pc.c \
	bif_repl.c \
	bif_xml.c \
	odbccat.c \
	sqlrbuf.c \
	sqlrcomp.c \
	sqlrrun.c \
	wi_xid.c

libwi_odbc_la_CFLAGS  = $(libwi_base_la_cflags)
libwi_odbc_la_CFLAGS  += -DUNIX_ODBC
libwi_odbc_la_LDLAGS  = -static

libwic_la_SOURCES = \
	blobio.c \
	CLIcr.c \
	CLIodbc3.c \
	CLIsql1.c \
	CLIsql2.c \
	CLIsql3.c \
	CLIsql3W.c \
	CLIuti.c \
	CLIw.c \
	datesupp.c \
	multibyte.c \
	numeric.c \
	sqlver.c \
	wirpc.c \
	wi_xid.c

libwic_la_SOURCES += \
	$(PLDEBUG_CLI_FILES)

libwic_la_CFLAGS  = @VIRT_AM_CFLAGS@
libwic_la_CFLAGS  += -I$(top_srcdir)/libsrc
libwic_la_CFLAGS  += -I$(top_srcdir)/libsrc/Dk
libwic_la_CFLAGS  += -I$(top_srcdir)/libsrc/plugin
libwic_la_CFLAGS  += -I$(top_srcdir)/libsrc/langfunc
libwic_la_CFLAGS  += -I$(top_srcdir)/libsrc/odbcsdk/include
libwic_la_CFLAGS  += -DOPSYS=\"@OPSYS@\" -DHOST=\"@host@\"
libwic_la_LDLAGS  = -static

###################################################################
#generated stuff

SQL_FILES		= \
	$(srcdir)/sys_unicode3_collations.sql \
	$(srcdir)/system.sql \
	$(srcdir)/system2.sql \
	$(srcdir)/qlog.sql \
	$(srcdir)/odbccat.sql \
	$(srcdir)/useraggr.sql \
	$(srcdir)/vt_text.sql \
	$(srcdir)/phrasematch.sql \
	$(srcdir)/hosting.sql

SQL_FILES_1		= \
	$(srcdir)/oledb.sql \
	$(srcdir)/information_schema.sql

SQL_FILES_2PC		= \
	$(srcdir)/2pc.sql

SQL_FILES_ADM		= \
	$(top_srcdir)/binsrc/vsp/admin/admin.sql \
	$(top_srcdir)/binsrc/vspx/browser/admin_dav_browser.sql

SQL_FILES_AUTO		= \
	$(srcdir)/autoexec.sql

SQL_FILES_DAV		= \
	$(top_srcdir)/binsrc/dav/dav.sql \
	$(top_srcdir)/binsrc/dav/dav_api.sql \
	$(top_srcdir)/binsrc/dav/dav_meta.sql \
	$(top_srcdir)/binsrc/dav/dav_acct.sql \
	$(top_srcdir)/binsrc/dav/dav_rdf_quad.sql \
	$(top_srcdir)/binsrc/vsp/admin/admin_dav/vfs.sql \
	$(top_srcdir)/binsrc/dav/davxml2rdfxml.xsl \
	$(top_srcdir)/binsrc/dav/davxml2n3xml.xsl \
	$(top_srcdir)/binsrc/dav/rdfxml2n3xml.xsl \
	$(top_srcdir)/binsrc/dav/n3xml2uriqahtml.xsl \
	$(top_srcdir)/binsrc/dav/uriqa.sql \
	$(top_srcdir)/binsrc/dav/dav_det.sql \
	$(top_srcdir)/binsrc/dav/DET_CatFilter.sql \
	$(top_srcdir)/binsrc/dav/DET_HostFs.sql \
	$(top_srcdir)/binsrc/dav/DET_ResFilter.sql \
	$(top_srcdir)/binsrc/dav/DET_PropFilter.sql \
	$(top_srcdir)/binsrc/dav/DET_RDFData.sql \
	$(top_srcdir)/binsrc/dav/DET_DynaRes.sql \
	$(top_srcdir)/binsrc/dav/Versioning/DET_Versioning.sql \
	$(srcdir)/xml_view.sql

SQL_FILES_DBP		= \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/dbpump_root.sql \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/oper_pars.sql \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/components.sql \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/comp_html.sql \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/comp_misc.sql \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/comp_rpath.sql \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/comp_tables.sql \
	$(top_srcdir)/binsrc/vsp/admin/dbpump/pars_init.sql

SQL_FILES_DDK		= \
	$(srcdir)/replddk.sql \
	$(top_srcdir)/binsrc/dav/davddk.sql \
	$(srcdir)/mail_cli.sql \
	$(top_srcdir)/binsrc/vsp/admin/admin_ddl.sql \
	$(top_srcdir)/binsrc/vsp/admin/admin_dav/vfsddk.sql \
	$(srcdir)/virtual_dir.sql \
	$(srcdir)/url_rewrite.sql

if WITH_IMSG
SQL_FILES_IMSG		 = \
	$(srcdir)/pop3_svr.sql \
	$(srcdir)/ftp.sql \
	$(srcdir)/nn_svr.sql \
	$(top_srcdir)/binsrc/vsp/admin/admin_news/admin_news.sql
endif

SQL_FILES_PLDBG		= \
	$(srcdir)/cov_report.xsl \
	$(srcdir)/cov_time.xsl

SQL_FILES_REPL		= \
	$(srcdir)/snapshot_repl.sql \
	$(srcdir)/repl.sql

SQL_FILES_SPARQL	= \
	$(srcdir)/ttlpv.sql \
	$(srcdir)/sparql.sql \
	$(srcdir)/sparql_io.sql \
	$(srcdir)/sparql_ui.sql \
	$(srcdir)/rdf_sponge.sql \
	$(srcdir)/rdf_schema_objects.sql \
	$(srcdir)/rdf_void.sql \
	$(srcdir)/rdflddir2.sql

SQL_FILES_SYS 		= \
	$(srcdir)/users.sql

SQL_FILES_UDDI		= \
	$(srcdir)/uddi.sql

SQL_FILES_VAD		= \
	$(top_srcdir)/binsrc/vad/vad_root.sql \
	$(top_srcdir)/binsrc/vad/vad_misc.sql \
	$(top_srcdir)/binsrc/vad/oper_pars.sql \
	$(top_srcdir)/binsrc/vad/pars_init.sql \
	$(top_srcdir)/binsrc/vad/vad_make.sql

SQL_FILES_VDB		= \
	$(srcdir)/vdb.sql

SQL_FILES_WS		= \
	$(top_srcdir)/binsrc/vsp/vsp_auth.sql \
	$(srcdir)/soap.sql \
	$(srcdir)/wsrp_ultim.xsl \
	$(srcdir)/wsrp_resp.xsl \
	$(srcdir)/wsrp_interm.xsl \
	$(srcdir)/wsrp_error.xsl \
	$(srcdir)/soap_sch.xsl \
	$(srcdir)/soap_import_sch.xsl \
	$(srcdir)/wsdl_expand.xsl \
	$(srcdir)/wsdl_parts.xsl \
	$(srcdir)/wsdl_import.xsl \
	$(srcdir)/wsdl2rdf.xsl \
	$(srcdir)/xmlrpc_soap.xsl \
	$(srcdir)/soap_xmlrpc.xsl \
	$(srcdir)/soap12_router.xsl \
	$(top_srcdir)/binsrc/ws/wsrm/wsrm_ddl.sql \
	$(top_srcdir)/binsrc/ws/wsrm/wsrm_xsd.sql \
	$(top_srcdir)/binsrc/ws/wsrm/wsrmcli.sql \
	$(top_srcdir)/binsrc/ws/wsrm/wsrmsrv.sql \
	$(top_srcdir)/binsrc/ws/wstr/wstr_ddl.sql \
	$(top_srcdir)/binsrc/ws/wstr/wstrcli.sql \
	$(top_srcdir)/binsrc/ws/wstr/wstrsrv.sql \
	$(top_srcdir)/binsrc/ws/wsrm/wsrmcall.xsl \
	$(srcdir)/rdf_net.sql \
	$(srcdir)/simile.sql \
	$(srcdir)/xrd2json.xsl \
	$(srcdir)/xml2json.xsl \
	$(srcdir)/http_auth.sql \
	$(srcdir)/xmla.sql \
	$(srcdir)/openxml.sql \
	$(top_srcdir)/binsrc/vspx/vspx.sql \
	$(top_srcdir)/binsrc/vspx/vspx_add_locations.xsl \
	$(top_srcdir)/binsrc/vspx/vspx_expand.xsl \
	$(top_srcdir)/binsrc/vspx/vspx_pre_xsd.xsl \
	$(top_srcdir)/binsrc/vspx/vspx_pre_sql.xsl \
	$(top_srcdir)/binsrc/vspx/vspx_log_format.xsl \
	$(top_srcdir)/binsrc/vspx/vspx.xsd \
	$(top_srcdir)/binsrc/vspx/vspx.xsl


git_head.c:FORCE
	@-$(SHELL) ./mkgit_head.sh

json_p.c json_p.h: $(srcdir)/json.y Makefile.am
	@$(GEN) $(YACC) -o json_p.c -vd -pjsonyy $(srcdir)/json.y

json_l.c: $(srcdir)/json.l json_p.h Makefile.am
	@$(GEN) $(LEX) -o json_l.c -Pjsonyy $(srcdir)/json.l


sqlwords.h: $(srcdir)/sqlwords.gperf Makefile.am
	@${GEN} --stdout ${GPERF} \
		-o sqlwords.h \
		-aCDGptr -Kkwd -L ANSI-C -k1,2,3,6,9,$$ \
		-Nlex_hash_kw \
		$(srcdir)/sqlwords.gperf

sql3.c sql3.h: sql3.y Makefile.am
	@$(GEN) $(YACC) -o sql3.c -pscn3yy -vd $(srcdir)/sql3.y

scn3.c: scn3.l sql3.c sqlwords.h Makefile.am
	@$(GEN) $(LEX) -o scn3.c -Pscn3yy $(srcdir)/scn3.l

scn3split.c: scn3.l sql3.c sqlwords.h Makefile.am
	@$(GEN) $(LEX) -o scn3split.c -Pscn3splityy $(srcdir)/scn3.l

$(top_srcdir)/binsrc/cached_resources/cached_resources.c:
	@echo "* Generating cached_resources.c"
	@cd $(top_srcdir)/binsrc/cached_resources && $(MAKE)

sql_code_cache.c: $(top_srcdir)/binsrc/cached_resources/cached_resources.c sql_code_cache_impl.c
	@echo "/* This file is automatically generated by Makefile */" > $@
	@echo "#include \"sql_code_cache_impl.c\"" >> $@
	@echo "#include \"$(top_srcdir)/binsrc/cached_resources/cached_resources.c\"" >> $@

xpathp.c xpathp.h : xpathp.y Makefile.am
	@$(GEN) $(YACC) -o xpathp.c -vd -pxpyy $(srcdir)/xpathp.y

xpathp_lex_props.c: list_lex_props.sh xpathp.y Makefile.am
	$(SHELL) $(srcdir)/list_lex_props.sh xpathp.y xpathp_lex_props.c

xpscn.c: xpscn.l xpathp.h Makefile.am
	@$(GEN) $(LEX) -o xpscn.c -Pxpyy $(srcdir)/xpscn.l

sparqlwords.h: sparqlwords.gperf Makefile.am
	@$(GEN) --stdout $(GPERF) -o $@ \
		-aCDGptr \
		-Kkwd \
		-L ANSI-C \
		-k1,2,3,5,7,$$ \
		--ignore-case \
		-Nsparql_lex_hash_kw \
		sparqlwords.gperf

sparql_p.c sparql_p.h: sparql_p.y Makefile.am
	@$(GEN) $(YACC) -o sparql_p.c -vd -psparyy $(srcdir)/sparql_p.y

sparql_lex_props.c: list_lex_props.sh sparql_p.y Makefile.am
	$(SHELL) $(srcdir)/list_lex_props.sh sparql_p.y sparql_lex_props.c

sparql_l.c: sparql_l.l sparql_p.h Makefile.am
	@$(GEN) $(LEX) -o sparql_l.c -Psparyy $(srcdir)/sparql_l.l

nquad_p.c nquad_p.h: nquad_p.y Makefile.am
	@$(GEN) $(YACC) -o nquad_p.c -vd -pnqyy $(srcdir)/nquad_p.y

turtle_p.c turtle_p.h: turtle_p.y Makefile.am
	@$(GEN) $(YACC) -o turtle_p.c -vd -pttlyy $(srcdir)/turtle_p.y

turtle_lex_props.c: list_lex_props.sh turtle_p.y Makefile.am
	$(SHELL) $(srcdir)/list_lex_props.sh turtle_p.y turtle_lex_props.c

turtle_l.c: turtle_l.l turtle_p.h Makefile.am
	@$(GEN) $(LEX) -o turtle_l.c -Pttlyy $(srcdir)/turtle_l.l


AWK_FILES = $(srcdir)/sql_to_c.awk Makefile.am

sql_code.c: $(SQL_FILES) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code.c \
		-f $(srcdir)/sql_to_c.awk \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES)

sql_code_1.c: $(SQL_FILES_1) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_1.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_1 \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_1)

sql_code_ddk.c: $(SQL_FILES_DDK) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_ddk.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_ddk \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_DDK)

sql_code_adm.c: $(SQL_FILES_ADM) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_adm.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_adm \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_ADM)

sql_code_dav.c: $(SQL_FILES_DAV) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_dav.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_dav \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_DAV)

sql_code_vad.c: $(SQL_FILES_VAD) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_vad.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_vad \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_VAD)

sql_code_dbp.c: $(SQL_FILES_DBP) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_dbp.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_dbp \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_DBP)

sql_code_uddi.c: $(SQL_FILES_UDDI) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_uddi.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_uddi \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_UDDI)

sql_code_imsg.c: $(SQL_FILES_IMSG) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_imsg.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_imsg \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_IMSG)

sql_code_auto.c: $(SQL_FILES_AUTO) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_auto.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_auto \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_AUTO)

sql_code_2pc.c: $(SQL_FILES_2PC) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_2pc.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_2pc \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_2PC)

sql_code_vdb.c: $(SQL_FILES_VDB) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_vdb.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_vdb \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_VDB)

sql_code_sparql.c: $(SQL_FILES_SPARQL) $(AWK_FILES) Makefile.am
	@${GEN} ${GAWK} \
		-o sql_code_sparql.c \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_sparql \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_SPARQL)

sql_code_sys.c: $(SQL_FILES_SYS) $(SQL_AWK_DEPS) Makefile.am
	@$(GEN) $(GAWK) \
		-o sql_code_sys.c  \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_sys \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_SYS)

sql_code_ws.c: $(SQL_FILES_WS) $(SQL_AWK_DEPS) Makefile.am
	@$(GEN) $(GAWK) \
		-o $@  \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_ws \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_WS)

sql_code_repl.c: $(SQL_FILES_REPL) $(SQL_AWK_DEPS) Makefile.am
	@$(GEN) $(GAWK) \
		-o $@  \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_repl \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_REPL)

sql_code_pldbg.c: $(SQL_FILES_PLDBG) $(SQL_AWK_DEPS) Makefile.am
	@$(GEN) $(GAWK) \
		-o $@  \
		-f $(srcdir)/sql_to_c.awk \
		-v init_name=_pldbg \
		-v pl_stats=$(PLSTATS) \
		$(SQL_FILES_PLDBG)


#
# JSON
#
JSO_FILES	= $(srcdir)/rdf_mapping.jso
JSO_AWK		= $(srcdir)/jso_reformat.awk

rdf_mapping_jso.h: $(JSO_FILES) $(JSO_AWK) Makefile.am
	@${GEN} ${GAWK} \
		-o rdf_mapping_jso.h \
		-f $(JSO_AWK) \
		-v "output_mode=h" \
		-v "h_wrapper=__RFD_MAPPING_JSO_H" \
		-v "init_name=rdf_mapping" \
		$(JSO_FILES)

rdf_mapping_jso.c: $(JSO_FILES) $(JSO_AWK) rdf_mapping_jso.h Makefile.am
	@${GEN} ${GAWK} \
		-o rdf_mapping_jso.c \
		-f $(JSO_AWK) \
		-v "output_mode=c" \
		-v "init_name=rdf_mapping" \
		$(JSO_FILES)

rdf_mapping_jso.ttl: $(JSO_FILES) $(JSO_AWK) Makefile.am
	@${GEN} ${GAWK} \
		-o rdf_mapping_jso.ttl \
		-f $(JSO_AWK) \
		-v "output_mode=ttl" \
		-v "init_name=rdf_mapping" \
		$(JSO_FILES)

rdf_mapping_jso.ttl-sample: $(JSO_FILES) $(JSO_AWK) Makefile.am
	@${GEN} ${GAWK} \
		-o rdf_mapping_jso.ttl-sample \
		-f $(JSO_AWK) \
		-v "output_mode=ttl-sample" \
		-v "init_name=rdf_mapping" \
		$(JSO_FILES)

.PHONY: generated
generated: \
	scn3.c \
	scn3split.c \
	sparql_l.c \
	sparql_p.c \
	sparql_p.h \
	sparqlwords.h \
	sql3.c \
	sql_code.c \
	sql_code_1.c \
	sql_code_2pc.c \
	sql_code_adm.c \
	sql_code_auto.c \
	sql_code_cache.c \
	sql_code_dav.c \
	sql_code_dbp.c \
	sql_code_ddk.c \
	sql_code_imsg.c \
	sql_code_pldbg.c \
	sql_code_repl.c \
	sql_code_sparql.c \
	sql_code_sys.c \
	sql_code_uddi.c \
	sql_code_vad.c \
	sql_code_vdb.c \
	sql_code_ws.c \
	sqlwords.h \
	turtle_l.c \
	turtle_p.c \
	turtle_p.h \
	xpathp.c \
	xpathp.h \
	xpscn.c


# ----------------------------------------------------------------------
#
#  Additional files to distribute
#
# ----------------------------------------------------------------------
EXTRA_DIST = \
	*.sql \
	*.xsl \
 	*.l \
	*.y \
	2pc_client.c \
	bif_gnw.c \
	bif_kerberoscli.c \
	bif_mts.c \
	bif_purify.c \
	bmcmp.c \
	box2any.c \
	cebits.c \
	cebitsdec.c \
	cedict1.c \
	cedictad.c \
	ceintd2.c \
	ceintd.c \
	ceintddec.c \
	cesearch.c \
	cevecf.c \
	ceveci.c \
	cevecins.c \
	coltry.c \
	cl_stubs.c \
	crypt.c \
	dvcmp.c \
	iodbcinst.c \
	jso_reformat.awk \
	list_lex_props.sh \
	mts_client.c \
	mts_com.cpp \
	mtx.cpp \
	name.c \
	plugin_gate.c \
	rdf_mapping.jso \
	rdf_mapping_jso.ttl \
	rdf_mapping_jso.ttl-sample \
	scn3split.c \
	sql3_vc.c \
	sql_code_cache_impl.c \
	sql_to_c.awk \
	sqlwords.gperf \
	sparqlwords.gperf \
	ssl.c \
	string_tmpl.c

FORCE:
