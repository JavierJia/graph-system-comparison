package edu.uci.ics.pregelix.compare.graphx

import scala.Array.canBuildFrom
import scala.reflect.ClassTag

import org.apache.spark.Logging
import org.apache.spark.SparkContext
import org.apache.spark.graphx.Edge
import org.apache.spark.graphx.Graph
import org.apache.spark.graphx.VertexId

object GraphLoader extends Logging {

  def loadWebmap[VD: ClassTag, ED: ClassTag](sc: SparkContext, path: String, defaultEdgeAttr: ED, defaultVetexAttr: VD): Graph[VD, ED] =
    {
      val startTime = System.currentTimeMillis
      var textRDD = sc.textFile(path);
      var edge = textRDD.flatMap(
        line => {
          var numbers = line.split(" ");
          var srcId: VertexId = numbers(0).trim.toLong;
          numbers.slice(2, numbers.size).map(num => Edge(srcId, num.trim.toLong, defaultEdgeAttr))
        })
      logInfo("It took %d ms to load the graph:%s".format(System.currentTimeMillis - startTime, path))
      Graph.fromEdges[VD,ED](edge, defaultVetexAttr);
    }
}