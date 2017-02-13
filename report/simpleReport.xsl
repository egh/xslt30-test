<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:f="http://myfunction"
    xmlns:r="http://www.w3.org/2012/11/xslt30-test-results"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.w3.org/2012/10/xslt-test-catalog" 
    version="3.0"
    expand-text="true">
    
    <xsl:output method="html" indent="yes"/>
    
    <xsl:variable name="catalog" select="document('../catalog.xml')"/>
    <xsl:variable name="test-sets" select="$catalog//test-set/@file[not(starts-with(., 'tests/sandp/'))]/document(.)"/>
    <xsl:variable name="test-cases" select="$test-sets/*/test-case"/>
    
    <xsl:variable name="results" as="element(result)*" xpath-default-namespace="">
        <result name="Saxon 9.8">submission/Saxon_9.8.xml</result>
        <result name="Saxon-JS">submission/Saxon-JS_1.0.xml</result>
        <result name="Parrot">submission/Parrot_2017.xml</result>
    </xsl:variable>
    
    <xsl:function name="f:dependencies" as="element(*)*">
        <xsl:param name="test" as="element(test-case)"/>
        <xsl:sequence select="$test/(dependencies|../dependencies)/*"/>
    </xsl:function>
    
    <xsl:function name="f:non-spec-dependencies" as="element(*)*">
        <xsl:param name="test" as="element(test-case)"/>
        <xsl:sequence select="$test/(dependencies|../dependencies)/*[not(self::spec)]"/>
    </xsl:function>
    
    <xsl:function name="f:is30" as="xs:boolean">
        <xsl:param name="test" as="element(test-case)"/>
        <xsl:sequence select="not(f:dependencies($test)[self::spec]/@value[not(f:allows30(.))])"/>
    </xsl:function>
    
    <xsl:function name="f:allows30" as="xs:boolean">
        <xsl:param name="spec" as="xs:string"/>
        <xsl:sequence select="tokenize($spec) = ('XSLT10+', 'XSLT20+', 'XSLT30', 'XSLT30+')"/>
    </xsl:function>
    
    <xsl:variable name="categories" as="map(*)*">
        <xsl:sequence select="map{'name':'all', 'filter': function($testcase) { f:is30($testcase) }}"/>
        <xsl:sequence select="map{'name':'Basic Conformance', 'filter': function($testcase) { f:is30($testcase) and empty(f:non-spec-dependencies($testcase))}}"/>
        <xsl:sequence select="map{'name':'Streaming', 'filter': f:dependency-filter('streaming')}"/>
        <xsl:sequence select="map{'name':'Schema Awareness', 'filter': f:dependency-filter('schema_aware') }"/>
        <xsl:sequence select="map{'name':'Serialization', 'filter': f:dependency-filter('serialization') }"/>       
        <xsl:sequence select="map{'name':'1.0 compatibility', 'filter': f:dependency-filter('backwards_compatibility')}"/>       
        <xsl:sequence select="map{'name':'Dynamic Evaluation', 'filter': f:dependency-filter('dynamic_evaluation')}"/>
        <xsl:sequence select="map{'name':'XPath 3.1', 'filter': f:dependency-filter('XPath_3.1')}"/>
        <xsl:sequence select="map{'name':'Higher Order Functions', 'filter': f:dependency-filter('higher_order_functions')}"/>
        
    </xsl:variable>
    
    <xsl:function name="f:dependency-filter" as="function(*)">
        <xsl:param name="feature" as="xs:string"/>
        <xsl:sequence select="function($testcase) { f:is30($testcase) and
            exists(f:non-spec-dependencies($testcase)[self::feature[@value = $feature and not(@satisfied = 'false')]]) and
            empty(f:non-spec-dependencies($testcase)[not(self::feature[@value = $feature])])}"/>
    </xsl:function>
    
    <xsl:template name="xsl:initial-template">
        <html>
            <head>
                <title>XSLT 3.0 Test Results</title>
            </head>
            <body>
                <h1>XSLT 3.0 Test Results</h1>
                <p>Test results were submitted for the following processors:</p>
                <ol>
                    <li><p><b>Exselt</b> is...</p></li>
                    <li><p><b>Parrot</b> is a pseudonym for a product produced by a company that is not a member of the Working Group and
                    that has not participated actively in the development of the specification. The product is on general release; as such
                    it should be regarded as an implementation of the 2015 Candidate Recommendation rather than the 2017 version. The test
                    results were not submitted by the vendor, but were obtained by a member of the working group using a hastily-written
                    test driver; as such, many of the test failures may be attributed either (a) to inadequacies in the test driver,
                    or (b) to changes in the spec since 2015.</p></li>
                    <li><p><b>Saxon 9.8</b> is the forthcoming version of the commercial Saxon-EE/J product for the Java platform, produced by
                    Saxonica. Tests were run on a development snapshot rather than a final quality release.</p></li>
                    <li><p><b>Saxon-JS</b> is an implementation of XSLT 3.0 written in Javascript designed to run in the browser, also from Saxonica. The product
                    shares a front end with Saxon/J, but the back end (run-time) was developed independently from scratch. This is a first release
                    of the product. Some of the test failures are unavoidable (for example, float arithmetic delivers double-precision results,
                    which is deemed non-conformant), but others will be lifted in time especially as Javascript 6 rolls out more completely
                    across the browsers. The results reported here were obtained using the Nashorn Javascript engine; results on other platforms
                    vary slightly.</p></li>
                </ol>
                <table border="1">
                    <thead>
                        <tr>
                            <td rowspan="2">Category</td>
                            <td rowspan="2"># of Tests</td>
                            <xsl:for-each select="$results">
                                <td colspan="3">{@name}</td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <xsl:for-each select="$results">
                                <td>Passed</td>
                                <td>Failed</td>
                                <td>Not Run</td>
                            </xsl:for-each>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="$categories">
                            <tr>
                                <xsl:variable name="category" select="."/>
                                <td>{?name}</td>
                                <td>{f:total(?filter)}</td>
                                <xsl:for-each select="$results">
                                    <xsl:variable name="score" select="f:score(string(.), $category?filter)" as="map(*)"/>
                                    <td>{$score?passed}</td>
                                    <td>{$score?failed}</td>
                                    <td>{$score?notrun}</td>
                                </xsl:for-each>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
                <p><emph>Note: Except for the first row, this table omits all tests with multiple dependencies. For example a test that requires
                support for both streaming and schema awareness will appear in the "all" category, but not in either the streaming or
                schema awareness categories.</emph></p>
                <xsl:call-template name="tests-not-run">
                    <xsl:with-param name="results" select="$results[@name = 'Saxon 9.8']"/>
                </xsl:call-template>
                <xsl:call-template name="report-against-success-criteria"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template name="report-against-success-criteria">
        <h1>Report against Success Criteria</h1>
        <blockquote>To demonstrate achievement of the criteria for transition to Proposed Recommendation the Working Group plans 
            to provide evidence of two independent and substantially complete implementations of the basic XSLT processor conformance 
            level as well as the optional streaming feature, and at least one substantially complete implementation of other optional 
            features defined in 27 Conformance. </blockquote>
        <h2>Basic Conformance</h2>
        
        <blockquote>...two independent and substantially complete implementations of the basic XSLT processor conformance 
            level</blockquote>
        
        <xsl:variable name="category" select="$categories[?name = 'Basic Conformance']"/>
        <xsl:variable name="filter" as="function(element(test-case)) as xs:boolean" select="$category?filter"/>
        <xsl:variable name="selected" select="$test-cases[$filter(.)]/@name"/>
        <xsl:variable name="total" select="count($selected)"/>
        <xsl:variable name="tests-with-two-passes" select="$selected[let $n := . return count(document($results)//r:test-case[@name = $n][@result = ('pass', 'wrongError')]) ge 2]"/>
        
        <p>There are <big>{$total}</big> tests that should be passed by a processor claiming basic conformance.</p>
        
        <p>Of these, <big>{count($tests-with-two-passes)} ({format-number(count($tests-with-two-passes) div $total, '99.99%')})</big> 
        were passed by at least two processors.</p>
        
        <h2>Streaming</h2>
        
        <blockquote>...two independent and substantially complete implementations of the optional streaming feature</blockquote>
        
        <xsl:variable name="category" select="$categories[?name = 'Streaming']"/>
        <xsl:variable name="filter" as="function(element(test-case)) as xs:boolean" select="$category?filter"/>
        <xsl:variable name="selected" select="$test-cases[$filter(.)]/@name"/>
        <xsl:variable name="total" select="count($selected)"/>
        <xsl:variable name="tests-with-two-passes" select="$selected[let $n := . return count(document($results)//r:test-case[@name = $n][@result = ('pass', 'wrongError')]) ge 2]"/>
        
        <p>There are <big>{$total}</big> tests that should be passed by a processor implementing the optional streaming feature.</p>
        
        <p>Of these, <big>{count($tests-with-two-passes)} ({format-number(count($tests-with-two-passes) div $total, '99.99%')})</big> 
            were passed by at least two processors.</p>
        
        <h2>Other optional features</h2>
        
        <blockquote>... and at least one substantially complete implementation of other optional 
            features defined in 27 Conformance.</blockquote>
        
        
        <xsl:for-each select="subsequence($categories, 4)">
            <xsl:variable name="category" select="."/>
            <h3>{?name}</h3>
            <xsl:variable name="filter" as="function(element(test-case)) as xs:boolean" select="?filter"/>
            <xsl:variable name="selected" select="$test-cases[$filter(.)]/@name"/>
            <xsl:variable name="total" select="count($selected)"/>
            <xsl:variable name="tests-with-one-pass" select="$selected[let $n := . return count(document($results)//r:test-case[@name = $n][@result = ('pass', 'wrongError')]) ge 1]"/>
            
            <p>There are <big>{$total}</big> tests that should be passed by a processor implementing the {?name} feature.</p>
            
            <p>Of these, <big>{count($tests-with-one-pass)} ({format-number(count($tests-with-one-pass) div $total, '99.99%')})</big> 
                were passed by at least one processor.</p>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="tests-not-run">
        <xsl:param name="results" as="element(Q{}result)*"/>
        <h1>Tests Not Run</h1>
        <xsl:for-each select="$results">
            <xsl:variable name="result" select="."/>
            <h2>{@name}</h2>
            <xsl:for-each select="$categories">
                <xsl:variable name="filter" select="?filter"/>
                <xsl:variable name="selected" select="$test-cases[$filter(.)]/@name"/>
                <xsl:variable name="results" select="doc($result)//r:test-case"/>
                <h3>{?name}</h3>
                <h4>Reported as not run</h4>
                <xsl:value-of select="$results[@name = $selected][@result = 'notRun']/@name"/>
                <h4>Not Reported</h4>
                <xsl:value-of
                    select="
                        $selected[let $n := .
                        return
                            not($results[@name = $n])]"
                />
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="f:total" as="xs:integer">
        <xsl:param name="filter" as="function(element(test-case)) as xs:boolean"/>
        <xsl:sequence select="count($test-cases[$filter(.)])"/>
    </xsl:function>

   <xsl:function name="f:score" as="map(*)">
       <xsl:param name="results-uri" as="xs:string"/>
       <xsl:param name="filter" as="function(element(test-case)) as xs:boolean"/>
       <xsl:variable name="selected" select="$test-cases[$filter(.)]/@name"/>
       <xsl:variable name="results" select="doc($results-uri)//r:test-case"/>
       <xsl:map>
           <xsl:map-entry key="'passed'" select="count($results[@name = $selected][@result=('pass', 'wrongError')])"/>
           <xsl:map-entry key="'failed'" select="count($results[@name = $selected][@result='fail'])"/>
           <xsl:map-entry key="'notrun'" select="count($results[@name = $selected][@result='notRun']) + 
               count($selected[let $n := . return not($results[@name = $n])])"/>
       </xsl:map>      
   </xsl:function>
</xsl:stylesheet>