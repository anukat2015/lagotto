var data = <%= raw @data %>;
var article_count = <%= Article.count %>;

var color = d3.scale.ordinal()
    .range(["#a17f78","#ad9a27","#c7c0b5"]);

var w = 200,
    h = 200,                          
    radius = Math.min(w, h) / 2;
    
var chart = d3.select("div#chart_status").append("svg")          
    .data([data]) 
    .attr("width", w) 
    .attr("height", h)
    .attr("class", "chart")
    .append("svg:g") 
    .attr("transform", "translate(100,100)")
 
var arc = d3.svg.arc() 
    .outerRadius(radius - 10)
    .innerRadius(radius - 40);
 
var pie = d3.layout.pie() 
    .sort(null) 
    .value(function(d) { return d.value; });
 
var arcs = chart.selectAll("g.slice") 
    .data(pie)        
    .enter()                
    .append("svg:g") 
    .attr("class", "slice"); 
 
arcs.append("svg:path")
    .attr("fill", function(d, i) { return color(i); } )
    .attr("d", arc);
    
arcs.append("svg:title")
    .text(function(d) { return d.data.value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + " " + d.data.name + " articles" });
    
chart.append("text")
    .attr("dy", 0)
    .attr("text-anchor", "middle") 
    .attr("class", "title")
    .text("Status");
    
chart.append("text")
    .attr("dy", 21)
    .attr("text-anchor", "middle") 
    .attr("class", "subtitle")
    .text("of articles");