很多人可能会使用 Perl 做 MVC 的框架来在自己的项目中开发，目前在 Perl 界最常用的三个框架分别是 Catalyst, Dancer 和 Mojolicious。我最开始接触的是 Catalyst ，后来使用 Dancer 。现在使用 Mojolicious (后面文章中使用 Mojo 来代指 Mojolicious )。另外，这三个框架都是直接原生支持 PSGI 接口的。
然后我因为在学习这些框架的同时，译了一些文章出来，所以在这。我也为新人选择框架来大约介绍一下相关的框架。希望能给你们提供一定的帮助。
 
 Catalyst
  
   
   Catalyst  我想老的写 Perl 的人都会知道，这可一直是业内标准的 Perl MVC 框架，提起 Perl 的 MVC 大家第一想想到的一定是它。它是功能丰富，灵活。您可以使用几乎所有的好的东西：各种模板系统, Moose 支持，在 CPAN 上以它的名字开头有很多插件。Catalyst  其它的优势是它的成熟和文档。国外有好几本书讲了如何建立和使用 Catalyst  来开发各种不同的应用。所以他成了我第一个接触的框架，因为复杂所以后来放弃使用了。
    
    MetaCPAN 数据
    主框架评分: 72
    模块总数：999 以上
    插件总数：482 
     
     在 metacpan 上他的东西也是最多的，最少上千的模块。但因为目前流量使用轻量级框架，所以他的评分并不高。
      
      但是要正确安装 Catalyst 是比较麻烦的.我以前做为新手第一次安装过程很痛苦，基本难得一帆风顺.常常会出一些小问题,让 Catalyst  没法正常工作,比如出现 Moose 或类似的东西和其他一些模块之间的冲突。它变得非常让人沮丧.因为他对于第三方的模块依赖非常多。要了解和要学习的内容也不少。
       
       后来 Catalyst 好象是在 5.8 还是什么时候全面转成 Moose 来重写了。
        

        在 Catalyst 中默认使用的 Controllers  的模型非常不错. 在 Mojolicious  中要做到这点,需要自己写访问控制的逻辑. 我很喜欢 Catalyst 使用 $c 来从 $self 中分离的用法. 我以前不喜欢在所有的控制器和方法上展开调度的规则( dispatching rules)。
        Dancer
         
         相比起 Catlyst 和 Mojolicious 来讲, Dancer 是非常的轻量。他是比起 Catalyst 和 Mojolicious 都简单，很象不完全的 Mojlicious 的一部分的功能（Mojolicious::Lite）。他对第三方的模块依赖也是介于这二者中间的，并不是非常多。总体来讲设计 Dancer 的体系还是相当不错的。开发 Dancer 非常的容易。这也是我第一个正式使用的 MVC 框架。
         第一次写 Web 应用的话，Dancer 可能是最简单的方案。就象 Ruby's Sinatra 一样简单。只是 Dancer 和 Sinatra 一样都是使用领域特定语言（DSL）。可能很多人并不喜欢这种东西。很多人只喜欢纯 Perl .
          
          MetaCPAN 数据
          主框架评分: 85
          模块总数：244
          插件总数：147
           
            
            在 metacpan 上，有关 Dancer 相关的模块，到本文写的时候，大约有 244 个。Dancer  的插件有 147 个，应用还是比较丰富的。
             
             可能因为作者感觉设计的问题，所以现在一直在开发 Dancer2 但目前还不太合适在生产环境中使用。所以现在 Dancer1 和 Dancer2 是并行的都在开发，给人的感觉有点乱。然后第二代也还没有完全可以在生产中使用。更新并不是很经常。注。第二代的 Dancer  更加面象对象，是使用 Moo 的技术来开发的。
              
              另外，不知道为什么 Dancer 的自动加载应用的功能，总是不好用。也不细研究了
               
               Mojolicious
                
                Mojolicious 并没想重写 Catalyst，使用纯 Perl 的全新的实现， 所以我们见不到多少 Catalyst 的影子。在新的 Mojo 中，不但支持象 Dancer 一样的 DSL, 也支持其它层级结构来开发，这样项目可以做处更加大。并且不象 Catalyst 一样使用 Moose 。所以在项目中很是方便。
                 
                 如果不使用 DSL 的话，有一个文件来统一管理所有的路径调度到相应的对象。本身比较 Catalyst 轻量多了，可以很好的和第三方模块集成。本身的模块技术性能非常的快，基本不用使用第三方的。并且这个模板技术是我所使用过的最强大的。
                  
                  因为 Mojo 常用的东西都是自己实现的，比如 DOM 选择器和 JSON 的解析都是自己实现，所以模块依赖非常少。不过他必须要在 Perl 5.10 以上才能跑。另外，它本身实现的 Web 服务器 Hypnotoad 也非常非常可靠。

                  提供的 Mojo::UserAgent 非常好用，因为原生支持 DOM 和 CSS 的选择器，并且能 JSON 来解析，基本上是抓数据什么的不二选择。
                   
                   MetaCPAN 数据
                   主框架评分: 116
                   模块总数： 228
                   插件总数： 169
                    

                     
                     Mojo 的插件在 metacpan 上比 Dancer 要多那么一点点有 169 个，从插件角度来讲，这个差别并不是很大。相关总模块有 228 个。可能因为 Mojo 给所有的东西都集成到本身所以少了很多东西的原因。
                      
                      有关 Mojo 的开发使用 Fayland 的评论就是”佩服sri的，开发那么活跃，几乎每个礼拜都有新版本 “。所以非常的合适使用，作者也非常关心自己的框架。作者本身也是多年的使用 Catlyst 的用户（也可能是开发都，我并没搞清楚)
